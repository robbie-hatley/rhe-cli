#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# file-mime-types.pl
# Prints the MIME types of all files in the current directory (and all subdirectories if a -r or --recurse
# option is used).
# Written by Robbie Hatley.
# Edit history:
# Mon Mar 20, 2023: Wrote it.
# Thu Aug 03, 2023: Renamed from "file-types.pl" to "file-mime-types.pl". Reduced width from 120 to 110.
#                   Removed "-l", and "--local" options, as these are already default. Improved help.
# Thu Sep 07, 2023: Nixed superfluous "double quotes" in help. Got rid of "/o" on all qr().
#                   Improved entry/exit message-printing in main (now using $pname).
# Thu Aug 15, 2024: -C63; got rid of unnecessary "use" statements.
# Sat Mar 15, 2025: Modernized; now using global vars & BEGIN for pname and compilation timing; added more
#                   options; now using predicate; updated mime types to recognize scripts and plain text.
##############################################################################################################

use v5.36;
use utf8;

use Cwd 'getcwd';
use File::Type;
use Time::HiRes 'time';

use RH::Dir;
use RH::Util;

# ======= VARIABLES: =========================================================================================

# System Variables:
$" = ', ' ; # Quoted-array element separator = ", ".

# Global Variables:
our    $pname;                                 # Declare program name.
BEGIN {$pname = substr $0, 1 + rindex $0, '/'} # Set     program name.
our    $cmpl_beg;                              # Declare compilation begin time.
BEGIN {$cmpl_beg = time}                       # Set     compilation begin time.
our    $cmpl_end;                              # Declare compilation end   time.
INIT  {$cmpl_end = time}                       # Set     compilation end   time.

# Local variables:

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $Debug     = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 0         ; # Be verbose?               bool      Shhhh!! Be quiet!!
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.

# Counters:
my $direcount = 0         ; # Count of directories processed by curdire().
my $filecount = 0         ; # Count of files matching target 'F' and RegExp "$RegExp".
my $predcount = 0         ; # Count of files also matching predicate "$Predicate".

# Set-up a file-typing functor and file-type variable:
my $typer = File::Type->new();
my $type = '';

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub stats   ; # Print statistics.
sub error   ; # Handle errors.
sub help    ; # Print help and exit.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Start execution timer:
   my $t0 = time;

   # Process @ARGV and set settings:
   argv;

   # Print program entry message if being terse or verbose:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      say STDERR "\nNow entering program \"$pname\" at timestamp $t0.";
      printf(STDERR "Compilation took %.3fms\n",1000*($cmpl_end-$cmpl_beg));
      say STDERR '';
   }

   # Print the values of all 8 settings variables if debugging:
   if ( 1 == $Debug ) {
      say STDERR "Options   = (@Opts)";
      say STDERR "Arguments = (@Args)";
      say STDERR "Debug     = $Debug";
      say STDERR "Help      = $Help";
      say STDERR "Verbose   = $Verbose";
      say STDERR "Recurse   = $Recurse";
      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
      say STDERR '';
   }

   # Process current directory (and all subdirectories if recursing) and print stats,
   # unless user requested help, in which case just print help:
   $Help and help or ($Recurse and RecurseDirs {curdire} or curdire) and stats;

   # Stop execution timer:
   my $t1 = time;

   # Print exit message if being terse or verbose:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      my $te = $t1 - $t0; my $ms = 1000 * $te;
      say    STDERR '';
      say    STDERR "Now exiting program \"$pname\" at timestamp $t1.";
      printf STDERR "Execution time was %.3fms.", $ms;
   }

   # Exit program, returning success code "0" to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV :
sub argv {
   # Get options and arguments:
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {           # For each element of @ARGV,
      /^--$/                 # "--" = end-of-options marker = construe all further CL items as arguments,
      and $end = 1           # so if we see that, then set the "end-of-options" flag
      and push @Opts, $_     # and push the "--" to @Opts
      and next;              # and skip to next element of @ARGV.
      !$end                  # If we haven't yet reached end-of-options,
      && ( /^-(?!-)$s+$/     # and if we get a valid short option
      ||  /^--(?!-)$d+$/ )   # or a valid long option,
      and push @Opts, $_     # then push item to @Opts
      or  push @Args, $_;    # else push item to @Args.
   }

   # Process options:
   for ( @Opts ) {
      /^-$s*h/ || /^--help$/    and $Help    =  1  ;
      /^-$s*e/ || /^--debug$/   and $Debug   =  1  ;
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0  ; # Default.
      /^-$s*t/ || /^--terse$/   and $Verbose =  1  ;
      /^-$s*v/ || /^--verbose$/ and $Verbose =  2  ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0  ; # Default.
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1  ;
   }

   # Get number of arguments:
   my $NA = scalar(@Args);

   # If user typed more than 2 arguments, and we're not debugging, print error and help messages and exit:
   if ( $NA > 2                  # If number of arguments > 2
        && !$Debug && !$Help ) { # and we're not debugging and not getting help,
      error($NA);                # print error message,
      help;                      # and print help message,
      exit 666;                  # and exit, returning The Number Of The Beast.
   }

   # First argument, if present, is a file-selection regexp:
   if ( $NA > 0 ) {              # If number of arguments > 0,
      $RegExp = qr/$Args[0]/o;   # set $RegExp to $args[0].
   }

   # Second argument, if present, is a file-selection predicate:
   if ( $NA > 1 ) {              # If number of arguments >= 2,
      $Predicate = $Args[1];     # set $Predicate to $args[1].
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire
{
   # Increment directory counter:
   ++$direcount;

   # Get current working directory:
   my $cwd = d getcwd;

   # Announce current working directory if being verbose:
   if ( 2 == $Verbose ) {
      say STDOUT "\nDirectory # $direcount: $cwd\n";
   }

   # Get list of fully-qualified paths of all regular files in current directory matching $RegExp:
   my @paths = glob_regexp_utf8($cwd, 'F', $RegExp);

   # Iterate through $curdirpaths and print the MIME type of each file:
   foreach my $path (@paths) {
      ++$filecount;
      local $_ = e $path;
      if (eval($Predicate)) {
         ++$predcount;
         curfile($path);
      }
   }
   return 1;
} # end sub curdire

sub curfile ($path) {
   $type = $typer->checktype_filename($path);
   if ( ! defined $type ) {$type = 'undefined';}

   # Don't accept "application/octet-stream" if extension gives type:
   if ( 'application/octet-stream' eq $type ) {
      my $name = get_name_from_path($path);
      if ( $name =~ m/\.txt$/ ) { $type = 'text/plain'         }
      if ( $name =~ m/\.au3$/ ) { $type = 'application/x-au3'  }
   }

   # Don't accept "text/script" for script files of common types:
   if ( 'text/script' eq $type ) {
      my $fl = '';    # First Line
      my $fh = undef; # File  Handle
      # Try to open the file; if we succeed, try to use first line to find out what KIND of script this is:
      if ( open($fh, '<', $path) ) {
         $fl = <$fh>;
         if ( length($fl) > 0 ) {
               if ( $fl  =~ m/perl/   ) { $type = 'application/x-perl'   }
            elsif ( $fl  =~ m/raku/   ) { $type = 'application/x-raku'   }
            elsif ( $fl  =~ m/python/ ) { $type = 'application/x-python' }
            elsif ( $fl  =~ m/sed/    ) { $type = 'application/x-sed'    }
            elsif ( $fl  =~ m/awk/    ) { $type = 'application/x-awk'    }
            elsif ( $fl  =~ m/apl/    ) { $type = 'application/x-apl'    }
            elsif ( $fl  =~ m/au3/    ) { $type = 'application/x-au3'    }
            elsif ( $fl  =~ m/bash/   ) { $type = 'application/x-bash'   }
            elsif ( $fl  =~ m/sh/     ) { $type = 'application/x-sh'     }
         }
         close $fh;
      }
   }
   printf("%-100s = %-30s\n", $path, $type);
   return 1;
}

# Print statistics for this program run if being terse or verbose:
sub stats {
   if ( 1 == $Verbose || 2 == $Verbose ) {
      say "\nStatistics for \"$pname\":";
      say "Navigated $direcount directories.";
      say "Found $filecount files matching target 'F' and RegExp \"$RegExp\".";
      say "Found $predcount paths also matching predicate \"$Predicate\".";
   }
   return 1;
} # end sub stats

# Handle errors:
sub error ($err_msg)
{
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);
   Error: you typed $err_msg arguments, but this program takes at most 1 argument,
   which, if present, must be a Perl-Compliant Regular Expression specifying
   which directory entries to process.
   END_OF_ERROR
   return 1;
} # end sub error

# Print help:
sub help
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "file-mime-types.pl", Robbie Hatley's nifty file MIME types printer.
   This program prints the MIME type of every file in the current directory
   (and all subdirectories if a -r or --recurse option is used).

   -------------------------------------------------------------------------------
   Command lines:

   file-types.pl -h | --help               (to print help and exit)
   file-types.pl [options] [arguments]     (to print MIME types of files)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Print diagnostics.
   -q or --quiet      Be quiet.                         (DEFAULT)
   -t or --terse      Be terse.
   -v or --verbose    Be verbose.
   -l or --local      DON'T recurse subdirectories.     (DEFAULT)
   -r or --recurse    DO    recurse subdirectories.
         --           End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -vr to verbosely and recursively process items.

   If two piled-together single-letter options conflict, the option
   appearing lowest on the options chart above will prevail.
   If two separate (not piled-together) options conflict, the right
   overrides the left.

   If you want to use an argument that looks like an option (say, you want to
   search for files which contain "--recurse" as part of their name), use a "--"
   option; that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   In addition to options, this program can take 1 or 2 optional arguments.

   Arg1 (OPTIONAL), if present, must be a Perl-Compliant Regular Expression
   specifying which file names to process. To specify multiple patterns, use the
   | alternation operator. To apply pattern modifier letters, use an Extended
   RegExp Sequence. For example, if you want to process items with names
   containing "cat", "dog", or "horse", title-cased or not, you could use this
   regexp: '(?i:c)at|(?i:d)og|(?i:h)orse'
   Be sure to enclose your regexp in 'single quotes', else BASH may replace it
   with matching names of entities in the current directory and send THOSE to
   this program, whereas this program needs the raw regexp instead.

   Arg2 (OPTIONAL), if present, must be a boolean predicate using Perl
   file-test operators. The expression must be enclosed in parentheses (else
   this program will confuse your file-test operators for options), and then
   enclosed in single quotes (else the shell won't pass your expression to this
   program intact). Also, "-M" and "-s" should be in (parentheses) else your
   predicate may be considered "ambiguous" by the Perl interpreter.
   Here are some examples of valid and invalid predicate arguments:
   '((-M) < 100)'     # VALID: Find files modified less-than-100 days ago
   '((-s) < 5000000)' # VALID: Find files at least 5MB in size
   '(-M) < 100'       # INVALID: missing outer parentheses (confuses Perl)
   '(-M  < 100)'      # INVALID: missing inner parentheses (confuses Perl)
   ((-M) < 100))      # INVALID: missing quotes (confuses shell)
   WARNING: If you use a predicate which excludes files which can have mime types,
   or includes files which CAN'T have mime types, this program will not perform
   correctly. Predicates can be useful, though, to specify file attributes such as
   sizes or dates.

   Arguments and options may be freely mixed, but the arguments must appear in
   the order Arg1, Arg2 (RegExp first, then File-Type Predicate); if you get them
   backwards, they won't do what you want, as most predicates aren't valid regexps
   and vice-versa.

   A number of arguments greater than 2 will cause this program to print an error
   message and abort.

   Happy type printing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
