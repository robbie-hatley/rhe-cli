#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# find-cjk-file-names.pl
# Written by Robbie Hatley.
#
# Edit history:
# Mon Mar 15, 2021: Wrote it.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Thu Oct 03, 2024: Got rid of Sys::Binmode and common::sense; added "use utf8".
# Mon Mar 10, 2025: Got rid of all given/when. Got rid of all prototypes and empty subs. Added signatures.
#                   Increased min ver from "5.32" to "5.36". Reduced width from 120 to 110. Added stackable
#                   single-letter options.
# Fri Apr 04, 2025: Now using "utf8::all" and "Cwd::utf8". Nixed "cwd_utf8", "d", "e".
##############################################################################################################

use v5.36;
use strict;
use warnings;
use warnings FATAL => "utf8";
use utf8;
use utf8::all;
use Cwd::utf8;
use Time::HiRes qw( time );
use RH::Dir;

# ======= VARIABLES: =========================================================================================

# ------- System Variables: ----------------------------------------------------------------------------------

$" = ', ' ; # Quoted-array element separator = ", ".

# ------- Global Variables: ----------------------------------------------------------------------------------

our    $pname;                                 # Declare program name.
BEGIN {$pname = substr $0, 1 + rindex $0, '/'} # Set     program name.
our    $cmpl_beg;                              # Declare compilation begin time.
BEGIN {$cmpl_beg = time}                       # Set     compilation begin time.
our    $cmpl_end;                              # Declare compilation end   time.
INIT  {$cmpl_end = time}                       # Set     compilation end   time.

# ------- Local variables: -----------------------------------------------------------------------------------

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $Debug     = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 0         ; # Be verbose?               0,1,2     Shhh! Be quiet!
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $Target    = 'A'       ; # Target                    F|D|B|A   Target all directory entries.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.
my $OriDir    = cwd       ; # Original directory.       cwd       Directory on program entry.

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed by curdire().
my $filecount = 0 ; # Count of files matching target.
my $findcount = 0 ; # Count of all CJK file names found.

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
   my @s0 = localtime($t0);

   # Process @ARGV and set settings:
   argv;

   # Print program entry message if being terse or verbose:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      say    STDERR "\nNow entering program \"$pname\"";
      printf STDERR "at %02d:%02d:%02d on %d/%d/%d.\n", $s0[2], $s0[1], $s0[0], 1+$s0[4], $s0[3], 1900+$s0[5];
      say    STDERR '';
   }

   # Also print compilation time if being verbose:
   if ( 2 == $Verbose ) {
      printf(STDERR "Compilation time was %.3fms\n",1000*($cmpl_end-$cmpl_beg));
      say STDERR '';
   }

   # Print the values of all variables if debugging or being verbose:
   if ( 1 == $Debug || 2 == $Verbose ) {
      say STDERR "pname     = $pname";
      say STDERR "cmpl_beg  = $cmpl_beg";
      say STDERR "cmpl_end  = $cmpl_end";
      say STDERR "Options   = (@Opts)";
      say STDERR "Arguments = (@Args)";
      say STDERR "Debug     = $Debug";
      say STDERR "Help      = $Help";
      say STDERR "Verbose   = $Verbose";
      say STDERR "Recurse   = $Recurse";
      say STDERR "Target    = $Target";
      say STDERR "RegExp    = $RegExp";
      say STDERR "Predicate = $Predicate";
      say STDERR '';
   }

   # Process current directory (and all subdirectories if recursing) and print stats,
   # unless user requested help, in which case just print help:
   $Help and help or ($Recurse and RecurseDirs {curdire} or curdire) and stats;

   # Stop execution timer:
   my $t1 = time;
   my @s1 = localtime($t1);

   # Print exit message if being terse or verbose:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      my $ms = 1000 * ($t1 - $t0);
      say    STDERR '';
      say    STDERR "Now exiting program \"$pname\"";
      printf STDERR "at %02d:%02d:%02d on %d/%d/%d. ", $s1[2], $s1[1], $s1[0], 1+$s1[4], $s1[3], 1900+$s1[5];
      printf STDERR "Execution time was %.3fms.", $ms;
   }

   # Exit program, returning success code "0" to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

sub argv {
   # Get options and arguments:
   my $end = 0;               # end-of-options flag
   my $s = '[a-zA-Z0-9]';     # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]';  # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {            # For each element of @ARGV:
      if ( !$end ) {             # If we're not at end-of-options:
         if ( /^--$/ ) {            # If we see "--",
            $end = 1;                  # then set the "end-of-options" flag
            push @Opts, $_;            # and push the "--" to @Opts
            next;                      # and move on to next item.
         }
         if ( /^-(?!-)$s+$/ ) {     # If we see a valid short option,
            push @Opts, $_;            # then push item to @Opts
            next;                      # and move on to next item.
         }
         if ( /^--(?!-)$d+$/ ) {    # If we see a valid long option,
            push @Opts, $_;            # then push item to @Opts
            next;                      # and move on to next item.
         }
      }
      push @Args, $_; # If we get to here, then the current command-line item must be construed as an
      next;           # "argument" rather than as an option, so push it it @Args and move on to next item.
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
      /^-$s*f/ || /^--files$/   and $Target  = 'F' ;
      /^-$s*d/ || /^--dirs$/    and $Target  = 'D' ;
      /^-$s*b/ || /^--both$/    and $Target  = 'B' ;
      /^-$s*a/ || /^--all$/     and $Target  = 'A' ; # Default.
   }

   # Get number of arguments:
   my $NA = scalar(@Args);

   # If user typed more than 2 arguments, and we're not debugging or getting help,
   # then print error and help messages and exit:
   if ( $NA > 2                  # If number of arguments > 2
        && !$Debug && !$Help ) { # and we're not debugging and not getting help,
      error($NA);                # print error message,
      help;                      # and print help message,
      exit 666;                  # and exit, returning The Number Of The Beast.
   }

   # First argument, if present, is a file-selection regexp:
   if ( $NA > 0 ) {              # If number of arguments > 0,
      $RegExp = qr/$Args[0]/o;   # set $RegExp to $Args[0].
   }

   # Second argument, if present, is a file-selection predicate:
   if ( $NA > 1 ) {              # If number of arguments >= 2,
      $Predicate = $Args[1];     # set $Predicate to $Args[1].
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

sub curdire {
   # Increment directory counter:
   ++$direcount;

   # Get current working directory:
   my $cwd = cwd;

   # If being very verbose, announce cwd:
   if ( $Verbose >= 2 ) {
      say "\nDirectory # $direcount: $cwd\n";
   }

   # Get list of file-info packets in $cwd matching $Target and $RegExp:
   my @names = sort {$a cmp $b} readdir_regexp_utf8($cwd, $Target, $RegExp, $Predicate);

   # Iterate through $curdirfiles and send each file to curfile():
   foreach my $name (@names) {curfile($cwd, $name)}

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

# Process current file:
sub curfile ($cwd, $name) {
   # Increment file counter:
   ++$filecount;
   # Print paths of all files with names containing at least one CJK (Chinese, Japanese, or Korean) character:
   if ( $name =~ m/\p{Block: CJK}/ ) {
      ++$findcount; # Count of all files which also match both regexps.
      say path($cwd, $name);
   }
   return 1;
} # end sub curfile

sub stats {
   if ( $Verbose >= 1 ) {
      warn "\n";
      warn "Statistics for running program \"$pname\"\n"
          ."on directory tree descending from \"$OriDir\":\n"
          ."Navigated $direcount directories.\n"
          ."Processed $filecount files.\n"
          ."Found $findcount files with names containing CJK characters.\n";
   }
   return 1;
} # end sub stats

sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program takes at most 1 argument,
   which, if present, must be a Perl-Compliant Regular Expression specifying
   which directory entries to process. Help follows:
   END_OF_ERROR
   return 1;
} # end sub error

sub help
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "find-cjk-file-names.pl". This program finds all files
   in the current directory (and all subdirectories if a -r or --recurse
   option is used) which have names containing Chinese, Japanese, or
   Korean ideographic characters belonging to the "CJK" Unicode block,
   and prints their fully-qualified paths.

   Command lines:
   find-cjk-file-names.pl -h | --help            (to print help)
   find-cjk-file-names.pl [options] [arguments]  (to find files)

   Description of options:
   Option:                      Meaning:
   "-h" or "--help"             Print help and exit.
   "-r" or "--recurse"          Recurse subdirectories.
   "-f" or "--target=files"     Target files only.
   "-d" or "--target=dirs"      Target directories only.
   "-b" or "--target=both"      Target both files and directories.
   "-a" or "--target=all"       Target all (files, directories, symlinks, etc).
   "-v" or "--verbose"          Print lots of extra statistics.

   Description of arguments:
   In addition to options, this program can take one optional argument which, if
   present, must be a Perl-Compliant Regular Expression specifying which items to
   process. To specify multiple patterns, use the | alternation operator.
   To apply pattern modifier letters, use an Extended RegExp Sequence.
   For example, if you want to search for items with names containing "cat",
   "dog", or "horse", title-cased or not, you could use this regexp:
   '(?i:c)at|(?i:d)og|(?i:h)orse'
   Be sure to enclose your regexp in 'single quotes', else BASH may replace it
   with matching names of entities in the current directory and send THOSE to
   this program, whereas this program needs the raw regexp instead.

   Happy CJK file finding!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
