#!/usr/bin/env perl

# This is a 110-character-wide ASCII-encoded Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# pseudo-random-integers-unlimied.pl
# Prints some pseudo-random integers.
# Edit history:
#    Sat Feb 06, 2021: Wrote first draft.
#    Sun Feb 07, 2021: Renamed from "pseudo-random-integers.pl" to "pseudo-random-integers-unlimied.pl".
#                      Severely refactored. Now generates pseudo-random integers to a googol and beyond.
#    Tue Feb 09, 2021: Fine-tuned range to be 2e102.
##############################################################################################################

use v5.32;
use bignum;
Math::BigFloat->accuracy(250);

# ======= VARIABLES: =========================================================================================
my $db    =  0 ; # Debug?
my $N     = 25 ; # Number of numbers
my $A     =  0 ; # Begin range
my $B     = 99 ; # End   range
my $width =  0 ; # Max width of numbers to print

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub process_argv     ();
sub print_rand_ints  ();
sub error            ($);
sub number_of_digits ($);

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Process @ARGV:
   process_argv();

   # Print random numbers:
   print_rand_ints();

   # We be done, so scram:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

sub process_argv ()
{
   my $help = 0;  # Just print help and exit?
   my $i    = 0;  # Index for @ARGV.
   for ( $i = 0 ; $i < @ARGV ; ++$i )
   {
      $_ = $ARGV[$i];
      if (/^-[\pL\pN]{1}$/ || /^--[\pL\pM\pN\pP\pS]{2,}$/)
      {
         if (/^-h$/ || /^--help$/) {$help = 1;}
         splice @ARGV, $i, 1; # Remove option from @ARGV.
         --$i; # Move index 1-left, so that the "++$i" above moves index back to current spot, with new item.
      }
   }

   if ($help) {print for <DATA>; exit(777);} # If user wants help, just print help and exit.
   my $NA = scalar(@ARGV);                   # Get number of arguments.
   my $msg;                                  # Message for sending to error().

   if ($NA !=  3)
      {$msg = 'wrong number of arguments.'                      ; error($msg); print for <DATA>; exit(666);}

   # Assign $N, $A, $B based on $ARGV[0], $ARGV[0], $ARGV[0]:
   $N =                     $ARGV[0] ; # $N is a regular perl numeric integer scalar in the 1..100000 range.
   $A = Math::BigFloat->new($ARGV[1]); # $A is a Math::BigFloat object in the -1e102 .. +1e102 range.
   $B = Math::BigFloat->new($ARGV[2]); # $B is a Math::BigFloat object in the -1e102 .. +1e102 range.

   if ($N !~ /^\d+(?:[eE]\d+)?$/)
      {$msg = 'arg1 must be a positive integer.'            ; error($msg); print for <DATA>; exit(666);}

   if ($N < 1 || $N > 100000)
      {$msg = 'arg1 must be in the range 1 .. 100000.'      ; error($msg); print for <DATA>; exit(666);}

   if ($A->is_nan())
      {$msg = 'arg2 must be a number.'                      ; error($msg); print for <DATA>; exit(666);}

   if ($A->blt(-1E102) || $A->bgt(1E102))
      {$msg = 'arg2 must be in the range -1E102 .. +1E102.' ; error($msg); print for <DATA>; exit(666);}

   if ($B->is_nan())
      {$msg = 'arg3 must be a number.'                      ; error($msg); print for <DATA>; exit(666);}

   if ($B->blt(-1E102) || $B->bgt(1E102))
      {$msg = 'arg3 must be in the range -1E102 .. +1E102.' ; error($msg); print for <DATA>; exit(666);}

   if ($ARGV[1]  >= $ARGV[2])
      {$msg = 'arg2 must be < arg3.'                        ; error($msg); print for <DATA>; exit(666);}

   my $widthA = number_of_digits($A);
   my $widthB = number_of_digits($B);
   if ($widthA > $width) {$width = $widthA;}
   if ($widthB > $width) {$width = $widthB;}
   $width += 1; # Allow room for sign.

   return 1;
} # end sub process_argv ()

sub print_rand_ints ()
{
   my ($i, $j, $rand104, $randfloat, $scaledfloat, $scaledint, @blocks, $block);
   for ( $i = 0 ; $i < $N ; ++$i )
   {
      @blocks=();
      push @blocks, Math::BigInt->new(Math::BigFloat->new(rand)->bfround(-13)*1e13) for (1..8);
      if ($db) {for my $block (@blocks) {printf("%013s", $block);} printf(" (blocks)\n");}
      $rand104 = Math::BigInt->new(0);
      for ( $j = 0 ; $j < 8 ; ++$j )
      {
         $rand104 += $blocks[$j] * 10**(13*(7-$j));
      }
      if ( $db) {printf("%0104s (rand104)\n", $rand104);}
      $randfloat   = Math::BigFloat->new($rand104);
      $scaledfloat = $A + (($B+1)-$A)*($randfloat/10**104);
      $scaledint   = Math::BigInt->new(int($scaledfloat));
      if (!$db) {printf("%${width}s\n", $scaledint);}
   }
   return 1;
} # end sub print_rand_ints ()

sub error ($)
{
   my $msg = shift;
   say "Error: $msg";
   say "Help follows:\n";
   return 1;
} # end sub error ($)

# Return number of digits in integer argument:
sub number_of_digits ($)
{
   my $n      = abs int shift;
   my $digits = 1;
   my $power  = 1;
   while ( $n / $power >= 10 )
   {
      ++$digits;
      $power *= 10;
   }
   return $digits;
}

=pod

10e100 =
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

10e100 - 1 =
 9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999

=cut

__DATA__
Welcome to "pseudo-random-integers.pl".
This program prints pseudo-random integers.

Command lines:
pseudo-random-integers.pl -h|--help       (to print this help then exit)
pseudo-random-integers.pl arg1 arg2 arg3  (to print pseudo-random integers)

Description of options:
Option:            Meaning:
"-h" or "--help"   Print this help and exit.

This program requires 3 mandatory arguments:
arg1 = number of random integers to print
arg2 = begin range of integers to choose random integers from
arg3 = end   range of integers to choose random integers from

Argument range limits:
arg1 must be a positive integer in the range 1 through 100000
arg2 must be an integer in the range -1E100 through +1E100
arg3 must be an integer in the range -1E100 through +1E100
arg2 must be less than arg3

Example:
pseudo-random-integers.pl 97 3 17
(Will print 97 pseudo-random integers in the range 3-through-17.)

Happy pseudo-random-integer printing!
Cheers,
Robbie Hatley,
programmer.
