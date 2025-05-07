#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# file-files-by-type.pl
# Moves files from current directory into appropriate subdirectories of the current directory (by default),
# or of the parent directory (if a "--one" or "-1" option is used), or of the grandparent directory (if a
# "--two" or "-2" option is used), based on file name extension. If the appropriate subdirectory does not
# exist, it will be created. If a file of the same name exists, the moved file will be enumerated.
#
# Edit history:
# Wed Nov 28, 2018: Started writing it.
# Sat Dec 08, 2018: Added code to create directories.
# Mon Apr 08, 2019: Added "two levels up" option.
# Fri Jul 19, 2019: Fixed minor formatting & comments issues, and added "~" to here-document in help().
# Tue Feb 16, 2021: Now using new GetFiles().
# Fri Mar 19, 2021: Now using Sys::Binmode.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; now using "common::sense".
# Fri Aug 19, 2022: Added "-0", "-1", "-2" options and corrected description above and help() below to match.
#                   Also changed the if-pile in curfile() to a given(). Also removed annoying duplication of
#                   success and/or failure messages, by erasing those messages from THIS script so that the
#                   equivalent messages in move_file() in RH::Dir will be the only ones printed.
# Tue Jul 30, 2024: Fixed many new bugs which cropped-up due to changes from Perl v5.32 to Perl v5.36.
# Wed Jul 31, 2024: Added both :prototype() and signatures () to all subroutines.
# Thu Aug 15, 2024: -C63; Width 120->110; erased unnecessary "use ..."; added protos & sigs to all subs.
# Wed Feb 26, 2025: Got rid of all prototypes and empty signatures. Commented subroutine predeclarations.
# Sun Apr 27, 2025: Now using "utf8::all" and "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d", "e".
# Tue May 06, 2025: Reverted to "-C63", "utf8", "Cwd", "d", "e", for Cygwin compatibility.
##############################################################################################################

use v5.36;
use utf8;
use Cwd;
use Time::HiRes 'time';
use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS ========================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub stats   ; # Print stats.
sub help    ; # Print help.

# ======= GLOBAL VARIABLES ===================================================================================

# Settings:
my @Opts   = ()   ; # options
my @Args   = ()   ; # arguments
my $Debug  = 0    ; # Print diagnostics and don't actually move files?
my $Levels = 0    ; # Go up how many levels before making subdirs? (Default is 0 levels.)
my $RegExp = '.+' ; # Regular expression. (Default is "all possible patterns of characters".)
my $Predicate = 1 ; # File-selection predicate.($string) {if ($Debug) {say STDERR $string}}

# Counters:
my $filecount = 0 ; # Count of files processed by curfile().
my $succcount = 0 ; # Count of files successfully filed-away.
my $failcount = 0 ; # Count of files we couldn't file-away.

# ======= MAIN BODY OF PROGRAM ===============================================================================

{ # begin main
   my $t0 = time;
   my $pname = get_name_from_path($0);
   argv;
   say STDERR "Now entering program \"$pname\".";
   say STDERR "\$Debug      = \"$Debug\".";

   say STDERR "\$RegExp  = \"$RegExp\".";

   curdire;

   stats;
   say    STDERR '';
   say    STDERR "Now exiting program \"$pname\".";
   printf STDERR "Execution time was %.3f seconds.", time - $t0;
   exit 0;
} # end main()

# ======= SUBROUTINE DEFINITIONS =============================================================================

# Process arguments:
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
      /^-$s*h/ || /^--help$/    and help() and exit(777) ;
      /^-$s*e/ || /^--debug$/   and $Debug   =  1        ;
      /^-$s*0/ || /^--zero$/    and $Levels  =  0        ;
      /^-$s*1/ || /^--one$/     and $Levels  =  1        ;
      /^-$s*2/ || /^--two$/     and $Levels  =  2        ;
   }

   # If debugging, print the options and arguments:
   if ( $Debug ) {
      say STDERR '';
      say STDERR "\$opts = (", join(', ', map {"\"$_\""} @Opts), ')';
      say STDERR "\$args = (", join(', ', map {"\"$_\""} @Args), ')';
   }

   # Get number of arguments:
   my $NA = scalar(@Args);

   # If user typed more than 2 arguments, and we're not debugging,
   # then print error and help messages and exit:
   if ( $NA >= 3 && !$Debug ) {  # If number of arguments >= 3 and we're not debugging,
      error($NA);                # print error message,
      help;                      # and print help message,
      exit 666;                  # and exit, returning The Number Of The Beast.
   }

   # First argument, if present, is a file-selection regexp:
   if ( $NA >= 1 ) {             # If number of arguments >= 1,
      $RegExp = qr/$Args[0]/o;   # set $RegExp to $Args[0].
   }

   # Second argument, if present, is a file-selection predicate:
   if ( $NA >= 2 ) {             # If number of arguments >= 2,
      $Predicate = $Args[1];     # set $Predicate to $Args[1].
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   my $curdir = d(getcwd);
   my @paths = glob_regexp_utf8($curdir, 'F', $RegExp, $Predicate);
   for my $path (@paths) {
      next unless is_data_file($path);
      next  if    is_meta_file($path);
      curfile $path;
   }
   return 1;
} # end sub curdire

# Process current file:
sub curfile ($path) {
   # Increment file counter:
   ++$filecount;

   # Get name and suffix of file:
   my $name     = get_name_from_path($path);
   my $suffix   = get_suffix($name) =~ s/^\.//r;

   # Use suffix "noex" to indicate "no suffix":
   if ('' eq $suffix) {$suffix = 'noex';}

   # Set $dir based on $Levels:
   my $dir;
   if    ( 0 == $Levels ) {$dir =            $suffix;}
   elsif ( 1 == $Levels ) {$dir = '../'    . $suffix;}
   elsif ( 2 == $Levels ) {$dir = '../../' . $suffix;}
   else                   {die "Error in \"file-files-by-type.pl\": Invalid \$Levels.\n$!\n";}

   # If debugging, just simulate moving files:
   if ($Debug) {
      say STDOUT "Simulated move:\n"
                ."Would have moved file \"$name\" to directory \"$dir\"";
   }

   # Else, move file for-real:
   else {
      # If the directory we need doesn't already exist, create it:
      mkdir e($dir) unless -e e($dir);

      # Move current file to correct directory:
      move_file($name, $dir)
      and ++$succcount and return 1
      or  ++$failcount and return 0;
   }
   # Return success code 1 to caller:
   return 1;
} # end sub curfile

# Print statistics:
sub stats {
   print("\nStats for \"file-files-by-type.pl\":\n");
   printf("Processed %5d files.\n",                   $filecount);
   printf("Filed     %5d files.\n",                   $succcount);
   printf("Failed    %5d file-filing attempts.\n",    $failcount);
   return 1;
} # end sub stats

# Handle errors:
sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most
   one argument, which, if present, must be a regular expression describing
   which items to process. Help follows:
   END_OF_ERROR
   return 1;
} # end sub error

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "file-files-by-type.pl". This program moves all files from the
   current directory into appropriate subdirectories of the current (or parent,
   or grandparent) directory, based on file type (eg: jpg, mp3, txt, exe).
   If the appropriate subdirectory of the target directory does not exist,
   it will be created. If a file of the same name exists, the moved file will
   be enumerated.

   -------------------------------------------------------------------------------
   Command line:
   program-name.pl [options] [regex]

   -------------------------------------------------------------------------------
   Description of options:

   Option:             Meaning:
   "-h" or "--help"    Print help and exit.
   "-e" or "--debug"   Print diagnostics; don't actually move files.
   "-0" or "--zero"    Move files to subfolders of folder 0 levels up (default)
   "-1" or "--two"     Move files to subfolders of folder 1 level  up
   "-2" or "--two"     Move files to subfolders of folder 2 levels up
   --                  End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up
   after a single hyphen; eg, use "-1e" to emulate filing files one-level-up
   and print diagnostics. To stop processing options and consider all further
   command-line items as being "arguments" instead, use a "--" option.

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of arguments:

   In addition to options, this program can take zero-or-more optional arguments
   which, if present, must be Perl-Compliant Regular Expressions specifying which
   items to process. To specify multiple patterns, use the | alternation operator.
   To apply pattern modifier letters, use an Extended RegExp Sequence.
   For example, if you want to search for items with names containing "cat",
   "dog", or "horse", title-cased or not, you could use this regexp:
   '(?i:c)at|(?i:d)og|(?i:h)orse'
   Be sure to enclose your regexp in 'single quotes', else BASH may replace it
   with matching names of entities in the current directory and send THOSE to
   this program, whereas this program needs the raw regexp instead.

   Happy file filing!
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
