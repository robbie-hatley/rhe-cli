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
##############################################################################################################

use v5.36;
use utf8;

use Time::HiRes 'time';

use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub stats   ; # Print statistics.
sub error   ; # Handle errors.
sub help    ; # Print help.

# ======= VARIABLES: =========================================================================================

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @opts      = ()        ; # options                   array     Options.
my @args      = ()        ; # arguments                 array     Arguments.
my $Db        = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 0         ; # Be verbose?               bool      Shhhh!! Be quiet!!
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.
my $Target    = 'A'       ; # Target                    F|D|B|A   All directory entries.
my $RegExp    = qr/^.+$/o ; # Regular expression.       regexp    Process all file names.
my $Predicate = 1         ; # Boolean predicate.        bool      Process all file types.

# Counters:
my $direcount = 0; # Count of directories processed by curdire.
my $filecount = 0; # Count of    files    processed by curfile.
my $findcount = 0; # Count of dir entries matching regexps.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   my $t0 = time;
   argv;

   if ($Verbose) {say "\nNow entering program \"" . get_name_from_path($0) . "\".";}
   if ($Verbose) {say "Verbose = $Verbose" ;}
   if ($Verbose) {say "Recurse = $Recurse" ;}
   if ($Verbose) {say "Target  = $Target"  ;}
   if ($Verbose) {say "RegExp  = $RegExp"  ;}

   # Process current directory (and all subdirectories if recursing) and print stats,
   # unless user requested help, in which case just print help:
   $Help and help or ($Recurse and RecurseDirs {curdire} or curdire) and stats;

   my $t1 = time;
   my $te = $t1 - $t0;

   if ($Verbose) {
      say "\nNow exiting program \"" . get_name_from_path($0) . "\". Execution time was $te seconds.";
   }

   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

sub argv {
   # Get options and arguments:
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {           # For each element of @ARGV,
      /^--$/                 # "--" = end-of-options marker = construe all further CL items as arguments,
      and $end = 1           # so if we see that, then set the "end-of-options" flag
      and push @opts, $_     # and push the "--" to @opts
      and next;              # and skip to next element of @ARGV.
      !$end                  # If we haven't yet reached end-of-options,
      && ( /^-(?!-)$s+$/     # and if we get a valid short option
      ||  /^--(?!-)$d+$/ )   # or a valid long option,
      and push @opts, $_     # then push item to @opts
      or  push @args, $_;    # else push item to @args.
   }

   # Process options:
   for ( @opts ) {
      /^-$s*h/ || /^--help$/    and $Help    =  1  ;
      /^-$s*e/ || /^--debug$/   and $Db      =  1  ;
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

   my $NA = scalar(@args);
   if ( $NA > 1 ) { error($NA); help; exit(666); }
   if ( $NA > 0 ) { $RegExp = qr/$args[0]/o;     }
   return 1;
} # end sub argv

sub curdire {
   # Increment directory counter:
   ++$direcount;

   # Get and announce current working directory:
   my $cwd = cwd_utf8;
   say "\nDirectory # $direcount: $cwd\n";

   # Get list of file-info packets in $cwd matching $Target and $RegExp:
   my $curdirfiles = GetFiles($cwd, $Target, $RegExp);

   # Iterate through $curdirfiles and send each file to curfile():
   foreach my $file (@{$curdirfiles}) {
      curfile($file);
   }
   return 1;
} # end sub curdire

# Process current file:
sub curfile ($file) {
   ++$filecount;
   # Print paths of all files with names containing at least one CJK (Chinese, Japanese, or Korean) character:
   if ( $file->{Name} =~ m/\p{Block: CJK}/ ) {
      ++$findcount; # Count of all files which also match both regexps.
      say $file->{Path};
   }
   return 1;
} # end sub curfile

sub stats {
   if ( 1 == $Verbose || 2 == $Verbose ) {
      warn "Statistics for this directory tree:\n";
      warn "Navigated $direcount directories.\n";
      warn "Processed $filecount files.\n";
      warn "Found $findcount paths with names containing CJK ideographic characters.\n";
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
