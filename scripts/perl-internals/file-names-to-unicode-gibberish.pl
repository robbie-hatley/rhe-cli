#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# file-names-to-unicode-gibberish.pl
# Renames ALL regular files in the current directory (and all subdirectories if -r or --recurse is used)
# to strings of 8 random Unicode characters characters. No regular files are spared. All file-name information
# will be lost; only the file bodies will remain, with gibberish names. This is very useful for testing the
# ability of OTHER scripts to rename files from pathological names to more-sensical names, hence I'm putting
# this script in my "Perl Internals" directory.
# Written by Robbie Hatley.
# Edit history:
# Thu Apr 03, 2025: Wrote it.
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
use RH::Util;

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
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Debug     = 0         ; # Debug?                    bool      Don't debug.
my $Verbose   = 0         ; # Be verbose?               0,1,2     Shhh! Be quiet!
my $Recurse   = 0         ; # Recurse subdirectories?   bool      Don't recurse.

# Counts of events in this program:
my $direcount = 0 ; # Count of directories processed.
my $filecount = 0 ; # Count of files encountered.
my $renacount = 0 ; # Count of files successfully renamed.
my $failcount = 0 ; # Count of failed file rename attempts.

# ======= SUBROUTINE PRE-DECLARATIONS ========================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub curfile ; # Process current file.
sub stats   ; # Print statistics.
sub help    ; # Print help and exit.

# ======= MAIN BODY OF PROGRAM ===============================================================================

{ # begin main
   # Start execution timer:
   my $t0 = time;
   my @s0 = localtime($t0);

   # Process @ARGV and set settings:
   argv;

   # Print program entry message if being terse or verbose:
   if ( $Verbose >= 1 ) {
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
      say STDERR "Debug     = $Debug";
      say STDERR "Help      = $Help";
      say STDERR "Verbose   = $Verbose";
      say STDERR "Recurse   = $Recurse";
      say STDERR '';
   }

   $Help and help and goto EXIT;

   say STDERR '';
   say STDERR 'WARNING: THIS PROGRAM RENAMES ALL REGULAR FILES IN THE CURRENT DIRECTORY';
   say STDERR '(AND IN ALL SUBDIRECTORIES IF -r OR --recurse IS USED) TO RANDOM STRINGS OF';
   say STDERR '8 UNICODE CHARACTERS. ALL INFORMATION CONTAINED IN THE FILE NAMES WILL BE LOST,';
   say STDERR 'AND ONLY THE FILE BODIES WILL REMAIN, WITH GIBBERISH NAMES.';
   say STDERR 'ARE YOU SURE THAT THAT IS WHAT YOU REALLY WANT TO DO???';
   say STDERR 'Press "<" (shift-comma) to continue, or any other key to abort.';
   my $char = get_character;
   exit 0 unless '<' eq $char;

   $Recurse and RecurseDirs {curdire} or curdire;
   stats;

   EXIT:
   my $t1 = time;
   my $ms = 1000 * (time - $t0);
   if ( $Verbose >= 1 ) {
      say    STDERR '';
      printf STDERR "Now exiting program \"%s\". Execution time was %.3fms.\n", $pname, $ms;
   }
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS =============================================================================

sub argv {
   # Get options:
   my $s = '[a-zA-Z0-9]';     # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]';  # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {            # For each element of @ARGV:
      if ( /^-(?!-)$s+$/ ) {     # If we see a valid short option,
         push @Opts, $_;            # then push item to @Opts
         next;                      # and move on to next item.
      }
      if ( /^--(?!-)$d+$/ ) {    # If we see a valid long option,
         push @Opts, $_;            # then push item to @Opts
         next;                      # and move on to next item.
      }
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

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   ++$direcount;
   my $cwd = cwd;
   if ($Verbose >= 2) {say STDERR "\nDir # $direcount: $cwd\n"}
   my @names = sort {$a cmp $b} readdir_regexp_utf8($cwd, 'F');
   foreach my $name (@names) {curfile $name}
   return 1;
} # end sub curdire

sub curfile ($old_name) {
   my $chars =
   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'              .
   'abcdefghijklmnopqrstuvwxyz'         x  2 .
   'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ'          .
   'ßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ'   x  2 .
   'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'       .
   'абвгдеёжзийклмнопрстуфхцчшщъыьэюя'  x  2 .
   '麦藁雪富士川町山梨県茶京愛永看的星道你是'       .
   '☺♪♫♭♮♯'                                  .
   '☿♀♁♂♃♄♅♆♇'                               ;

   # Try to find a random file name that doesn't already exist in file's directory:
   my $new_name = '' ;
   my $noex     = 0  ;
   my $fails    = 0  ;
   while (!$noex) {
      $new_name .= substr $chars, int rand length $chars, 1 for 0..7;
      if ( ! -e $new_name ) {$noex = 1}
      else                  {++$fails }
      if ( $fails >= 500  ) {
         warn "Failed to find a new name for \"$old_name\".\n";
         warn "Moving on to next file.\n";
         return 0;
      }
   }

   # Attempt rename:
   rename_file($old_name, $new_name)
   and ++$renacount and say STDOUT "Renamed: $old_name => $new_name" and return 1
   or  ++$failcount and say STDOUT "Failed:  $old_name => $new_name" and return 0;
} # end sub curfile ($file)

sub stats {
   if ( $Verbose ) {
      say STDERR '';
      say STDERR "Statistics for program \"randomize-file-names.pl\":";
      say STDERR "Navigated $direcount directories.";
      say STDERR "Encountered $filecount regular files.";
      say STDERR "Successfully randomized the names of $renacount files.";
      say STDERR "Tried-but-failed to randomize the names of $failcount files.";
   }
   return 1;
} # end sub stats

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "file-names-to-unicode-gibberish", Robbie Hatley's nifty utility for
   turning the names of all regular files in the current directory (and all
   subdirectories if -r or --recurse is used) into strings of 8 random Unicode
   characters. All regular files are processed, including meta files and hidden
   files. All file-name extensions will be erased.

   This purpose of this program is primarily to test OTHER file-renaming scripts,
   to check their ability to rename from from something truly pathological to
   something more-sensical. Hence I've put this script in my "perl-internals"
   directory.

   -------------------------------------------------------------------------------
   Command Lines:

   file-names-to-unicode-gibberish  -h | --help    (to print help)
   file-names-to-unicode-gibberish [Opts] [Args]   (to randomize names)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Print diagnostics.
   -q or --quiet      Be quiet. (Default.)
   -t or --terse      Be terse.
   -v or --verbose    Be verbose.
   -l or --local      DON'T recurse subdirectories. (Default.)
   -r or --recurse    DO    recurse subdirectories.

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -vr to verbosely and recursively process items.

   If two piled-together single-letter options conflict, the option
   appearing lowest on the options chart above will prevail.
   If two separate (not piled-together) options conflict, the right
   overrides the left.

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of arguments:

   This program ignores all arguments.


   Happy file-name destruction!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end help
