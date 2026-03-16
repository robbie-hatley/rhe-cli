#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# unique-pi-1000.pl
# Prints the indexes and values of every substring of 10 contiguous unique digits within the first 1000 digits
# of the decimal expansion of π.
# Written by Robbie Hatley.
# Edit history:
# Tue Mar 10, 2026: Wrote it.
##############################################################################################################

use v5.36;
use utf8::all;
use List::Util 'uniqnum';

# ======= VARIABLES: =========================================================================================

# ------- System Variables: ----------------------------------------------------------------------------------

$" = '' ; # Quoted-array element separator = '' (empty string).

# ------- Global Variables: ----------------------------------------------------------------------------------

our    $pname;                                 # Declare program name.
BEGIN {$pname = substr $0, 1 + rindex $0, '/'} # Set     program name.

# ------- Local variables: -----------------------------------------------------------------------------------

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $Debug     = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 0         ; # Be verbose?               0,1,2     Be quiet.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub uniπ    ; # Print indexes & values of substrings of 10 contiguous unique digits within π.
sub BLAT    ; # Print messages only if debugging.
sub help    ; # Print help and exit.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Start execution timer:
   my $t0 = time;
   my @s0 = localtime($t0);

   # Process @ARGV and set settings:
   argv;

   # Print program entry message if being terse or verbose:
   if ( $Verbose >= 1 ) {
      printf STDERR "Now entering program \"$pname\" at %02d:%02d:%02d on %d/%d/%d.\n\n",
      $s0[2], $s0[1], $s0[0], 1+$s0[4], $s0[3], 1900+$s0[5];
   }

   # If being verbose, print the values of all variables except counters, after processing @ARGV:
   if ( $Verbose >= 2 ) {
      say  "Debug message: Values of variables after running argv():\n"
         . "pname     = $pname     \n"
         . "Options   = (@Opts)    \n"
         . "Arguments = (@Args)    \n"
         . "Debug     = $Debug     \n"
         . "Help      = $Help      \n"
         . "Verbose   = $Verbose   \n";
   }

   # Process current directory (and all subdirectories if recursing) and print stats,
   # unless user requested help, in which case just print help:
   if ($Help) {help;}
   else       {uniπ;}

   # Stop execution timer:
   my $t1 = time;
   my @s1 = localtime($t1);

   # Print exit message if being terse or verbose:
   if ( $Verbose >= 1 ) {
      my $te = $t1 - $t0; my $ms = 1000 * $te;
      printf STDERR "\nNow exiting program \"$pname\" at %02d:%02d:%02d on %d/%d/%d.\n",
      $s1[2], $s1[1], $s1[0], 1+$s1[4], $s1[3], 1900+$s1[5];
      printf STDERR "Execution time was %.3fms.\n", $ms;
   }

   # Exit program, returning success code "0" to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV:
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
      /^-$s*h/ || /^--help$/      and $Help    =  1  ;
      /^-$s*e/ || /^--debug$/     and $Debug   =  1  ;
      /^-$s*q/ || /^--quiet$/     and $Verbose =  0  ;
      /^-$s*t/ || /^--terse$/     and $Verbose =  1  ; # Default.
      /^-$s*v/ || /^--verbose$/   and $Verbose =  2  ;
   }

   # (Ignore all non-option arguments.)

   # Return success code 1 to caller:
   return 1;
} # end sub argv

#
sub uniπ {
   my @π1000digits = split //,
      '3141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067'
    . '9821480865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819'
    . '6442881097566593344612847564823378678316527120190914564856692346034861045432664821339360726024914127'
    . '3724587006606315588174881520920962829254091715364367892590360011330530548820466521384146951941511609'
    . '4330572703657595919530921861173819326117931051185480744623799627495673518857527248912279381830119491'
    . '2983367336244065664308602139494639522473719070217986094370277053921717629317675238467481846766940513'
    . '2000568127145263560827785771342757789609173637178721468440901224953430146549585371050792279689258923'
    . '5420199561121290219608640344181598136297747713099605187072113499999983729780499510597317328160963185'
    . '9502445945534690830264252230825334468503526193118817101000313783875288658753320838142061717766914730'
    . '3598253490428755468731159562863882353787593751957781857780532171226806613001927876611195909216420198';
   BLAT("Debug msg in\"unique-pi-1000.pl\":\nFirst 1000 digits of pi =\n@π1000digits");
   for ( my $πidx = 0 ; $πidx < 991 ; ++$πidx ) {
      my @π10slice = @π1000digits[ $πidx+0 .. $πidx+9 ];
      my @π10uniq = uniqnum @π10slice;
      BLAT("Debug msg in\"unique-pi-1000.pl\":\nSlice = @π10slice\nUniq  = @π10uniq");
      if ( 10 == scalar @π10uniq ) {
         say '';
         say "index = $πidx";
         say "value = @π10uniq"
      }
   }
}

# Print messages only if debugging:
sub BLAT ($string) {if ($Debug) {say STDERR $string}}

# Print help:
sub help {
   print STDERR ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "$pname". This program prints the indexes and values of every
   substring of 10 contiguous unique digits within the first 1000 digits
   of the decimal expansion of π.

   -------------------------------------------------------------------------------
   Command lines:

   $pname  -h | --help                      (to print this help and exit)
   $pname  [options] [Arg1] [Arg2] [Arg3]   (to print unique digits in π)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print this help and exit.
   -e or --debug      Print diagnostics.
   -q or --quiet      Be quiet. (DEFAULT)
   -t or --terse      Be terse.
   -v or --verbose    Be verbose.
   --                 End of options (all further CL items are arguments).

   -------------------------------------------------------------------------------
   Description of Arguments:

   This program ignores all non-option arguments.

   END_OF_HELP
   return 1;
} # end sub help
