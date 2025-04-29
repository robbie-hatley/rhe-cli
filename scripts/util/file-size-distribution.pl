#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# file-size-distribution.pl
# Prints the distribution of file sizes in the current directory (and all subdirs if a -r or --recurse option
# is used).
#
# Author: Robbie Hatley
# Creation date: Sun Apr 17, 2016
#
# Edit history:
# Sun Apr 17, 2016: Wrote first draft.
# Thu Dec 21, 2017: Converted to logarithmic and reduced bins to 13.
# Tue Dec 26, 2017: Improved anti-log(0) code.
# Wed Feb 17, 2021: Refactored to use the new GetFiles(), which now requires a fully-qualified directory
#                   as its first argument, target as second, and regexp (instead of wildcard) as third.
# Sat Feb 20, 2021: Got rid of "Settings" hash. All subs now have prototypes.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Thu Aug 03, 2023: Upgraded from "use v5.32;" to "use v5.36;". Got rid of prototypes and started using
#                   signatures instead. Renamed from "file-size-statistics.pl" to "file-size-stats.pl".
#                   Got ride of "common::sense" (antiquated). Reduced width from 120 to 110. Improved help.
# Sat Sep 02, 2023: Updated main. Updated argv. Got rid of all /o on qr().
# Wed Sep 06, 2023: Re-named from "file-size-stats.pl" to "file-size-distribution.pl".
# Thu Sep 07, 2023: No-longer printing directories (no point, just spams scrollback). Entry, exit, error,
#                   debug, and help messages are to STDERR, but size distribution is now to STDOUT.
# Thu Oct 03, 2024: Got rid of Sys::Binmode.
# Thu Feb 06, 2025: Got rid of "strict" and "warnings".
# Sun Apr 27, 2025: Now using "utf8::all" and "Cwd::utf8". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d", "e".
##############################################################################################################

use v5.36;
use utf8::all;
use Cwd::utf8;
use Time::HiRes 'time';
use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ;
sub curdire ;
sub logsize ;
sub dist    ;
sub error   ;
sub help    ;

# ======= VARIABLES: =========================================================================================

# Settings:                  # Meaning of setting:        Possible values:    Meaning of default:
my $Db = 0                 ; # Print diagnostics?         bool                Don't debug.
my $Recurse   = 0          ; # Recurse subdirectories?    bool                Don't recurse.
my $RegExp    = qr/^.+$/   ; # Regular expression.        regexp              Process all file names.

# NOTE: There is no $Verbose variable in this program, because the whole point of this program is to print
# information on file sizes, to telling the program to be quiet would be prevent it from doing its job.

# NOTE: There are no $Target or $Predicate variables in this program, because we're interested only in
# regular files, because those are the files that are using all the storage space, and answering the question
# "What's using the storage space???" is what this program is all about.

# NOTE: When I say "regular files", I mean Perl file-test-operator predicate "-f _ && !-d _ && !-l _".
# That still allows any of -b -c -p -S -t to be true, but that's OK, because "weird" files can still take-up
# storage space, and we are interested in tallying ALL files ("weird" or not) that take-up storage space.

# Counters:
my $direcount = 0          ; # Count of directories navigated.
my $filecount = 0          ; # Count of regular files matching $RegExp.

# Make array of 13 size bins. $size_bins[i] represents number of files with int(floor(log(size)) = i.
my @size_bins;
foreach (0..12) {$size_bins[$_] = 0};

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Load time and program variables:
   my $t0 = time;
   my $pname = substr $0,1+rindex $0,'/';

   # Get and process options and arguments:
   argv;

   # Print entry message:
   say    STDERR "Now entering program \"$pname\".";
   say    STDERR "\$Db        = $Db";
   say    STDERR "\$Recurse   = $Recurse";
   say    STDERR "\$RegExp    = $RegExp";

   # Load size bins:
   $Recurse and RecurseDirs {curdire} or curdire;

   # Print size distribution
   dist;

   # Print exit message and exit:
   say    STDERR '';
   say    STDERR "Now exiting program \"$pname\".";
   printf STDERR "Execution time was %.3f seconds.\n", time - $t0;
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

sub argv {
   # Get options and arguments:
   my @opts = ();            # options
   my @args = ();            # arguments
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {
      /^--$/ && !$end        # "--" = end-of-options marker = construe all further CL items as arguments,
      and $end = 1           # so if we see that, then set the "end-of-options" flag
      and next;              # and skip to next element of @ARGV.
      !$end                  # If we haven't yet reached end-of-options,
      && ( /^-(?!-)$s+$/     # and if we get a valid short option
      ||  /^--(?!-)$d+$/ )   # or a valid long option,
      and push @opts, $_     # then push item to @opts
      or  push @args, $_;    # else push item to @args.
   }

   # Process options:
   for ( @opts ) {
      /^-$s*h/ || /^--help$/    and help and exit 777 ;
      /^-$s*e/ || /^--debug$/   and $Db      =  1     ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0     ;
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1     ;
   }
   if ( $Db ) {
      say STDERR "\$opts = (", join(', ', map {"\"$_\""} @opts), ')';
      say STDERR "\$args = (", join(', ', map {"\"$_\""} @args), ')';
   }

   # Process arguments:
   my $NA = scalar(@args);     # Get number of arguments.
   if ( $NA >= 1 ) {           # If number of arguments >= 1,
      $RegExp = qr/$args[0]/;  # set $RegExp to $args[0].
   }
   if ( $NA >= 2 && !$Db ) {   # If number of arguments >= 2 and we're not debugging,
      error($NA);              # print error message,
      help;                    # and print help message,
      exit 666;                # and exit, returning The Number Of The Beast.
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Return int(log10(file size)) with knife-edge rounding-error protection
# (ie, protect against int(0.99999973) vs int(1.00000142):
sub logsize ($file) {
   if ($Db) {say "In logsize; file name = \"$file->{Name}\".";}
   my $size_bin =                         # Make bin.
   0 == $file->{Size} ?                   # If file is empty,
   0                                      # set size_bin to 0,
   : int(log($file->{Size}+0.1)/log(10)); # else set size_bin to ln(size+0.1)/ln(10)
   return $size_bin;                      # Return bin.
} # end sub logsize ($file)

# Process current directory:
sub curdire {
   ++$direcount;

   # Get current working directory:
   my $curdir = cwd;

   # Get list of entries in current directory matching $RegExp:
   my $curdirfiles = GetFiles($curdir, 'F', $RegExp);

   # Iterate through all entries in current directory which match $RegExp
   # and increment the appropriate size_bin counter for each file:
   foreach my $file (@{$curdirfiles}) {
      ++$filecount;
      ++$size_bins[logsize($file)];
   }

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

sub dist {
   say STDOUT '';
   say STDOUT "Navigated $direcount directories.";
   say STDOUT "Found $filecount regular files matching RegExp \"$RegExp\".";
   say STDOUT "File-size distribution for this tree:";
   for (0..12) {
      printf STDOUT "Number of files with size 10^%2d bytes = %6d\n", $_, $size_bins[$_];
   }
   return 1;
} # end sub stats

sub error ($NA) {
   print STDERR ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: You typed $NA arguments, but this program takes 0 or 1 arguments.
   Help follows:
   END_OF_ERROR
} # end sub error ($NA)

sub help {
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "file-size-stats.pl". This program prints file-size stats for all
   regular files in the current directory (and all subdirectories if a -r or
   --recurse option is used).

   -------------------------------------------------------------------------------
   Command lines:

   file-size-stats.pl [-h|--help]         (to print this help and exit)
   file-size-stats.pl [options] [Arg1]    (to print file-size stats)

   -------------------------------------------------------------------------------
   Description of options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Print diagnostics.
   -l or --local      DON'T recurse subdirectories.                      (DEFAULT)
   -r or --recurse    DO    recurse subdirectories.
         --           End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -er to print diagnostics and recursively process items.

   If multiple conflicting separate options are given, later overrides earlier.
   If multiple conflicting single-letter options are piled after a single hyphen,
   the result is determined by this descending order of precedence: herl.

   If you want to use an argument that looks like an option (say, you want to
   search for files which contain "--recurse" as part of their name), use a "--"
   option; that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of arguments:

   In addition to options, this program can take 1 optional argument, which, if
   present, must be a Perl-Compliant Regular Expression specifying which files to
   print size stats for. To specify multiple patterns, use the | alternation
   operator. To apply pattern modifier letters, use an Extended RegExp Sequence.
   For example, if you want to print size stats for items with names containing
   "cat", "dog", or "horse", title-cased or not, you could use this regexp:
   '(?i:c)at|(?i:d)og|(?i:h)orse'
   Be sure to enclose your regexp in 'single quotes', else BASH may replace it
   with matching names of entities in the current directory and send THOSE to
   this program, whereas this program needs the raw regexp instead.

   If the number of arguments is not 0 or 1, this program will print an error
   message and abort.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
