#!/usr/bin/env perl
# Filename: "gear-ratio.pl".
# Description: Calculates effective gear ratio of a train of gears,
# and applies it to an input RPM to obtain an output RPM.
# Written by Robbie Hatley.
# Edit history:
#   Fri Mar 21, 2025: Wrote it.

# ======= PRAGMAS AND MODULES: ===============================================================================

use v5.36;
use strict;
use warnings;

use Scalar::Util qw( looks_like_number );
use bigrat       qw( lib GMP a 50      );

# ======= VARIABLES: =========================================================================================

my @Opts  = ()    ;
my @Args  = ()    ;
my $Debug = 0     ;
my $Help  = 0     ;

# ======= SUBROUTINE PREDECLARATIONS: ========================================================================

sub argv;
sub gear_ratio;
sub help;

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   argv;
   $Help and help and exit 777;
   gear_ratio;
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV:
sub argv {
   # Get options and arguments:
   foreach (@ARGV) {
      if (/^-/) {push @Opts, $_}
      else      {push @Args, $_}
   }

   # Process options:
   foreach (@Opts) {
      /^-\p{L}*h/ || /^--help$/  and $Help  = 1;
   }

   # Return success code 1 to caller:
   return 1;
}

# Calculate and print output RPM:
sub gear_ratio {
   my $IRPM = 0; if (@Args) {$IRPM = shift @Args;}
   my $ORPM = $IRPM;
   my $i = 0;
   while (scalar(@Args) >= 2) {
      my $x = shift @Args;
      my $y = shift @Args;
      $ORPM *= ($x/$y);
      ++$i;
   }
   say "Output = ${ORPM}RPM.";
   return 1;
}

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to Robbie Hatley's nifty gear-ratio program. Given an "input" RPM and
   an even number of positive integers representing the gear ratios of a train of
   gears, this program will output the corresponding "output" RPM.

   -------------------------------------------------------------------------------
   Command lines:

   gear-ratio.pl -h | --help              (to print this help and exit)
   gear-ratio.pl IRPM T1 T2 T3 T4 T5 T6   (to calculate output RPM)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print this help and exit.

   All other options are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   In addition to options, this program takes an odd number of command-line
   arguments:

   gear-ratio.pl IRPM T1 T2 T3 T4 T5 T6...

   IRPM is input RPM
   T1 and T2 are first  gear ratio.
   T3 and T4 are second gear ratio.
   T5 and T6 are third  gear ratio.
   Etc.

   IRPM can be any real number.
   T1, T2, etc, should be positive integers.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
}
