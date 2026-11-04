#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# swapbits.pl
# Toggles the parity of certain bits in the rightmost byte of every input character and prints result.
# Does not alter the input source.
# Written by Robbie Hatley.
# Edit history:
# Mon Nov 02, 2026: Wrote it.
##############################################################################################################

use v5.40;
use utf8::all;

# ======= SUBROUTINE PREDECLARATIONS: ========================================================================

sub help;

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main

   # If user wants help, just print help and exit:
   /^-h$/ || /^--help$/ and help and exit for @ARGV;

   # Filter input to output:
   while (<>) {
      chomp;
      my @chars = split //, $_;
      for ( my $i = 0 ; $i <= $#chars ; ++$i ) {
         my $ord = ord($chars[$i]);
         next if $ord  < 0b00100000; # control characters
         next if $ord == 0b00100000; # space
         next if $ord == 0b00110101; # 5
                 $ord ^= 0b00010101;
         $chars[$i] = chr($ord);
      }
      $_=join('',@chars)."\n";
      print;
   }

   # Exit app:
   exit;

} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Print help:
sub help {
   print STDERR ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "swapbits.pl". This program toggles the parity of the 4th, 6th, and
   8th bits (left-to-right, 1-based counting) of the least-significant byte of the
   Unicode codepoint of each character of the input, and writes the result to
   STDOUT. Control characters, spaces, and "5" are not altered.

   This program is a "filter", meaning that it outputs an altered COPY of its
   input, and the input source is not altered.

   Note that this is a reversible cipher, so running text through this twice
   reverts it to its original state.

   -------------------------------------------------------------------------------
   Command lines:

   swapbits.pl -h | --help   (to print this help and exit)
   swapbits.pl               (to swap bits)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print this help and exit.

   This program cheerfully ignores all other options.

   -------------------------------------------------------------------------------
   Description of Arguments:

   This program cheerfully ignores all arguments.


   Happy bit swapping!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
