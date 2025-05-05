#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# merge-numbered-files.pl
# Merges two batches of numbered files in two given directories having same prefix, same suffix, and same
# number of digits. This program first renumbers files in the "source" directory as necessary so that the
# lowest source file number is 1 higher than the highest destination file number. Then it moves all files
# from the source directory to the destination directory.
#
# This program does not delete or alter any files (though it does rename and move them), and it does not
# rename, move, create, or delete any directories. Nor does it change the codepoint order of the files
# within either the source batch or the destination batch (though it does force the entire source batch
# to have codepoint orders greater-than the files in the destination batch).
#
# This script is based-on and very-similar-to my earlier script titled "merge-batches" (now retired).
# But that script was intended to be used for Olympus digital camera JPG photos only, whereas this script is
# is for general files; and that script deleted certain files and directories, whereas this script doesn't
# delete anything.
#
# That being said, the primary usefulness of this program will still be unscrambling the numbering mess caused
# by a digital camera which resets its numbering on you after a card change. Just dump the contents of the
# first card into "dest_dir", dump the contents of the second card into "srce_dir", and do this:
#    merge-numbered-files.pl 'dscn' '4' '.jpg' 'srce_dir' 'dest_dir'
# and voila, files are now in chronological order.
#
# Written by Robbie Hatley, starting Sunday February 07, 2016.
#
# Edit history:
#
# Sun Feb 07, 2016: Starting writing it as "merge-batches.pl".
# Sun Dec 26, 2017: Created this version, "merge-numbered-files.pl", and now using 5.026_001.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate.
# Sat Nov 20, 2021: Now using "v5.32", "common::sense", and "Sys::Binmode"
# Tue Nov 30, 2021: Fixed wide-character bug due to bad use of "d" and readdir in while loop (again!!!).
# Tue Nov 30, 2021: Fixed "finds no files" bug due to not coupling appropriate variable to m//. Tested: Works.
# Sat Dec 04, 2021: Reformatted and corrected titlecard.
# Mon Mar 03, 2025: Got rid of "common::sense".
# Tue Apr 29, 2025: Now using "utf8::all". Simplified shebang to "#!/usr/bin/env perl". Nixed all "d" and "e".
#                   Increased min ver from "v5.32" to "v5.36". Reduced width from 120 to 110.
#                   Shortened subroutine names.
# Sun May 04, 2025: Reverted from "utf8::all" to "utf8" for Cygwin compatibility.
##############################################################################################################

use v5.36;
use utf8;
use Time::HiRes 'time';

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv;
sub merge;
sub stats;
sub error;
sub help;

# ======= VARIABLES: =========================================================================================

$, = ", "; # Set quoted-list separator to "comma space".
our $pname; # Declare program-name variable.
BEGIN {$pname = substr $0, 1 + rindex $0, '/'} # Store program name in a variable.
my @Args      = () ; # Arguments.
my @Opts      = () ; # Options.
my $Help      = 0  ; # Print help and exit?
my $Debug     = 0  ; # Pring diagnostics?
my $prefix    = '' ; # Prefix.
my $digits    = 0  ; # Number of digits in each serial number.
my $suffix    = '' ; # Suffix.
my $dir1      = '' ; # Batch 1 directory.
my $dir2      = '' ; # Batch 2 directory.
my $dir1count = 0  ; # Count of files in first    batch.
my $dir2count = 0  ; # Count of files in second   batch.
my $bothcount = 0  ; # Count of files in combined batch.

# ======= MAIN BODY OF PROGRAM: ==============================================================================
{ # begin main
   # Start execution timer:
   my $t0 = time;
   my @s0 = localtime($t0);

   # Print entry message:
   print("\nNow entering program \"$pname\".\n\n");

   # Process @ARGV:
   argv;

   # If debugging, print values of settings:
   if ($Debug) {
      say "In \"$pname\", just ran argv():";
      say "\@Opts   = (@Opts)";
      say "\@Args   = (@Args)";
      say "\$prefix = $prefix";
      say "\$digits = $digits";
      say "\$suffix = $suffix";
      say "\$dir2   = $dir2  ";
      say "\$dir1   = $dir1  ";
   }

   # If user wants help, print help; else merge batches and print stats:
   $Help and help or merge and stats;

   # Stop execution timer:
   my $t1 = time; my $te = $t1 - $t0; my $ms = 1000 * $te;

   # Print exit message and exit, returning success code 0 to operating system:
   printf STDERR "\nNow exiting program \"%s\".\nExecution time was %0.3fms\n", $pname, $ms;
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS =============================================================================

sub argv {
   # Get options and arguments:
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {           # For each element of @ARGV:
      !$end                  # If we have not yet reached end-of-options,
      && /^--$/              # and we see an "--" option,
      and $end = 1           # set the "end-of-options" flag
      and push @Opts, '--'   # and push "--" to @Opts
      and next;              # and skip to next element of @ARGV.
      !$end                  # If we have not yet reached end-of-options,
      && ( /^-(?!-)$s+$/     # and if we see a valid short option
      ||  /^--(?!-)$d+$/ )   # or a valid long option,
      and push @Opts, $_     # then push item to @Opts
      and next;              # and skip to next element of @ARGV.
      push @Args, $_;        # Otherwise, push item to @Args.
   }

   # Process options:
   for ( @Opts ) {
      /^-$s*h/ || /^--help$/    and $Help    =  1  ;
      /^-$s*e/ || /^--debug$/   and $Debug   =  1  ;
   }

   # Get number of arguments:
   my $NA = scalar(@Args);

   # If number of arguments is out-of-range and we're not getting help or debugging,
   # print error and help messages and exit:
   (5 != $NA) && !$Help && !$Debug and error($NA) and help and exit 666;

   # Set settings:
   $NA >= 1 and $prefix = $Args[0];
   $NA >= 2 and $digits = $Args[1];
   $NA >= 3 and $suffix = $Args[2];
   $NA >= 4 and $dir1   = $Args[3];
   $NA >= 5 and $dir2   = $Args[4];
   $dir1 =~ s(/$)(); # Snip trailing backslash (if any) on $dir1.
   $dir2 =~ s(/$)(); # Snip trailing backslash (if any) on $dir2.

   # Return success code 1 to caller:
   return 1;
}

sub merge {
   my $min1       = 0 + '9' x $digits ; # Minimum source     number.
   my $max2       = 0                 ; # Maximum desination number.
   my $boost      = 0                 ; # Amount by which to boost the numbers of the source files.

   # Read source directory:
   my @srcenames  = (); # List of names of files in source directory.
   my $dh1 = undef; # Handle for directory 1.
   opendir($dh1, e($dir1)) or die "Can't open dir \"$dir1\"\n$!\n";
   while (my $name1 = readdir $dh1) {
      next if '.'  eq $name1;
      next if '..' eq $name1;
      if ($Debug) {
         say '';
         say "In \"$pname\", in merge(), in while1.";
         say "Current name = \"$name1\".";
      }
      my $path1 = $dir1 . '/' . $name1;
      next unless -f e($path1);
      next unless $name1 =~ m/^$prefix\d{$digits}$suffix$/;
      my $number = 0 + substr($name1, length($prefix), $digits);
      $min1 = $number if $number < $min1;
      push @srcenames, $name1;
      ++$dir1count;
      ++$bothcount;
   }
   closedir $dh1;

   # Read destination directory:
   my $dh2 = undef; # Handle for directory 2.
   opendir($dh2, e($dir2)) or die "Can't open dir \"$dir2\"\n$!\n";
   while (my $name2 = readdir $dh2) {
      next if '.'  eq $name2;
      next if '..' eq $name2;
      if ($Debug) {
         say '';
         say "In \"$pname\", in merge(), in while2.";
         say "Current name = \"$name2\".";
      }
      my $path2 = $dir2 . '/' . $name2;
      next unless -f e($path2);
      next unless $name2 =~m/$prefix\d{$digits}$suffix$/;
      my $number = 0 + substr($name2, length($prefix), $digits);
      $max2 = $number if $number > $max2;
      ++$dir2count;
      ++$bothcount;
   }
   closedir $dh2;

   $boost = $max2 - $min1 + 1;

   say "\$min1  = $min1";
   say "\$max2  = $max2";
   say "\$boost = $boost";

   # Iterate through the source files, boost their numbers, and move them to the destination directory:
   foreach (@srcenames) {
      my $name1   = $_;
      my $oldpath = $dir1 . '/' . $name1;
      my $oldnmbr = 0 + substr($name1, length($prefix), $digits);
      my $newnmbr = $oldnmbr + $boost;
      my $name2   = sprintf "$prefix%0${digits}d$suffix", $newnmbr;
      my $newpath = $dir2 . '/' . $name2;
      say "$oldpath => $newpath";
      $newpath eq $oldpath and die "\nError: new path same as old!\n$!\n";
      rename($oldpath, $newpath) or die "\nError: rename failed!\n$!\n";
   }

   # Return success code 1 to caller:
   return 1;
} # end sub merge

sub stats {
   print("\nStatistics for program \"$pname\":\n");
   say "Batch 1 contained     $dir1count files.";
   say "Batch 2 contained     $dir2count files.";
   say "Merged batch contains $bothcount files.";

   # Return success code 1 to caller:
   return 1;
} # end sub stats

sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error in "$pname": You typed $NA arguments,
   but this program requires exactly 5 arguments.
   Help follows.
   END_OF_ERROR

   # Return success code 1 to caller:
   return 1;
} # end sub error

sub help {
   print ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "$pname". This program merges-together two
   batches of numbered files with same prefix, number of digits, and suffix.
   This program first "boosts" (increases) the numbers of the files in the source
   directory so that they are all at least 1-greater-than the numbers of the files
   in the destination directory. This program then moves the renumbered files from
   the source directory to the destination directory.

   This program does not delete or alter any files (though it does rename and move
   them), and it does not rename, move, create, or delete any directories. Nor
   does it change the codepoint order of the files within either the source batch
   or the destination batch (though it does force the entire source batch to have
   codepoint orders greater-than the files in the destination batch).

   The primary usefulness of this program is unscrambling the numbering mess
   caused by a digital camera which resets its numbering on you after a card
   change. For example, if your camera produces files with names that look like
   "dscn3702.jpg", just dump the contents of the first card into "dest_dir",
   dump the contents of the second card into "srce_dir", and do this:

      merge-numbered-files.pl 'dscn' '4' '.jpg' 'srce_dir' 'dest_dir'

   and voila, your files are now in chronological order in "dest_dir" and
   "srce_dir" will now be empty.

   -------------------------------------------------------------------------------
   Command lines:

   $pname -h|--help   (to print this help and exit)
   $pname arguments   (to merge numbered file batches)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Print diagnostic messages.

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -eh to print both diagnostic and help messages.

   If you want to use an argument that looks like an option (say, you want to
   use directories named "--help" and "--debug") use a "--" option; that will
   force all command-line entries to its right to be considered "arguments"
   rather than "options".

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   This program takes exactly 5 mandatory arguments:

   Arg 1: Prefix (all of the characters, if any, before the serial number).
   Arg 2: Number of digits in each file's serial number.
   Arg 3: Suffix (all of the characters, if any, after the serial number).
   Arg 4: Source      directory.
   Arg 5: Destination directory.

   (NOTE: always enclose each argument in 'single quotes' or your shell may send
   the wrong arguments to this program.)

   This program will look for files with names matching the pattern you specify
   with Arguments 1, 2, 3 in the directories you specify in Arguments 4, 5.
   (To specify a file-name format lacking a prefix or suffix, set Arg 1 or Arg 2
   to '', the empty string.) This program  will then renumber the files of the
   source batch if necessary to assure that the lowest-numbered file in the
   source batch is 1 higher than the highest-numbered file in the destination
   batch. Finally, it will then move the files in the source directory to the
   destination directory.

   For example, to merge batches of files like these:

      In directory './srce': x0001.png x0002.png x0003.png x0004.png
      In directory './dest': x8376.png x8377.png x8378.png x8379.png

   the command line would look like:

      $pname 'x' '4' '.png' 'srce' 'dest'

   This program would then renumber the files of the source batch,
   boosting all of their numbers by 8379 (to prevent name conflicts,
   and so that they come AFTER the destination files in sort order),
   then it will move the source files to the destination directory.
   The contents of the two directories would then be this:

      In directory './srce': (empty)
      In directory './dest': x8376.png x8377.png x8378.png x8379.png
                             x8380.png x8381.png x8382.png x8383.png

   This is particularly useful when swapping-out cards in a digital
   camera and the camera resets the file numbering on you.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP

   # Return success code 1 to caller:
   return 1;
} # end sub help
