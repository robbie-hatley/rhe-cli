#!/usr/bin/env perl

# This is a 110-character-wide ASCII-encoded Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# "triangle.pl"
# Given 3 positive real numbers, tells whether a triangle can be formed with sides of those lengths.
# Written by Robbie Hatley.
# Edit history:
# Sat Jun 05, 2021: Wrote it.
##############################################################################################################

use v5.36;
use Scalar::Util qw( looks_like_number );
use List::Util   qw( any );

# ======= PERL-INTERNALS VARIABLES: ==========================================================================

$"=', '; # Set field separator for interpolated arrays to "comma space".

# ======= LEXICAL VARIABLES: =================================================================================

# Setting:      Default Value:   Meaning of Setting:         Range:     Meaning of Default:
my @sides     = ()           ; # Sides of triangle, ascndg.  0.1+       Empty before processing @ARGV.

# ======= SUBROUTINES: =======================================================================================

# Handle errors:
sub error ($msg) {
   warn "Error in \"triangle.pl\": $msg.\n";
   warn "Use a \"-h\" or \"--help\" option to get help.\n";
   exit(666); # Something devilish happened.
} # end sub error

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "[insert Program Name here]". This program does blah blah blah
   to all files in the current directory (and all subdirectories if a -r or
   --recurse option is used).

   -------------------------------------------------------------------------------
   Command lines:

   program-name.pl -h | --help       (to print this help and exit)
   program-name.pl Arg1 Arg2 Arg3    (to determine if a triangle can be made)

   -------------------------------------------------------------------------------
   Description of options:

   Option:            Meaning:
   -h or --help       Print help and exit.

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of arguments:

   Unless getting help, this program must have exactly 3 arguments, which must be
   positive real numbers. This program will then state whether a triangle can be
   formed with sides of those lengths.

   Happy triangulating!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help

# Process @ARGV :
sub argv {
   # First set some local variables we'll need:
   my @opts = ();      # options
   my @args = ();      # arguments
   my $s = '[a-zA-Z]'; # single-hyphen allowable chars (English letters)
   my $d = '[a-zA-Z]'; # double-hyphen allowable chars (English letters)

   # For each element of @ARGV, if it's a valid short or long option, push it to @opts, else push it to @args:
   for (@ARGV) {if (/^-(?!-)$s+$/ || /^--(?!-)$d+$/) {push @opts, $_} else {push @args, $_}}

   # Process options:
   for (@opts) {/^-$s*h$s*$/ || /^--help$/ and help and exit 777}

   # If inputs are bad, print error message and exit:
   if ( 3 != scalar                  @args ) {error('Number of arguments is not 3')}
   if ( any {!looks_like_number($_)} @args ) {error('Non-numeric argument(s)')     }
   if ( any {$_<=0}                  @args ) {error('Argument(s) not positive')    }

   # Otherwise, set @sides to a sorted copy of @args:
   @sides = sort {$a <=> $b} @args;

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# ======= MAIN BODY OF PROGRAM: ==============================================================================

# Process @ARGV:
argv;

# If we get to here, @sides will now be three positive numbers in ascending order.
# These sides represent a triangle if-and-only-if $sides[0]+$sides[1] > $sides[2]:
say "Sides = (@sides)";
if ( $sides[0]+$sides[1] > $sides[2] ) {say "YES, a triangle CAN be formed with sides of these lengths."}
else                                   {say "NO, a triangle CAN'T be formed with sides of these lengths."}
