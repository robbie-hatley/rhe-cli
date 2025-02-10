#!/usr/bin/env -S perl -CSDA

=pod

--------------------------------------------------------------------------------------------------------------
COLOPHON:
This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。麦藁雪、富士川町、山梨県。

--------------------------------------------------------------------------------------------------------------
TITLE BLOCK:
Solutions in Perl for The Weekly Challenge 186-2.
Written by Robbie Hatley on Fri Nov 10, 2023.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 2: Unicode Makeover
Submitted by: Mohammad S Anwar
You are given a string with possible unicode characters.
Create a subroutine sub makeover($str) that replace the
unicode characters with ascii equivalent. For this task,
let us assume it only contains alphabets.

Example 1:
Input: $str = 'ÃÊÍÒÙ';
Output: 'AEIOU'

Example 2:
Input: $str = 'âÊíÒÙ';
Output: 'aEiOU'

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
I'll use "use Unicode::Normalize 'NFD';" to decompose all the diacriticals from their base letters,
then I'll use "s/\pM//" to erase the diacriticals from the strings.

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be
a double-quoted array of single-quoted strings, apostrophes escaped, in proper Perl syntax, like so:
./ch-2.pl "('金ÂЩg茶ýöё♪', '♫mêиlàlóxц', '狗ТüCâб金川', 'Cân\'t!')"

Output is to STDOUT and will be each input array followed by the corresponding output.

=cut

# ------------------------------------------------------------------------------------------------------------
# PRAGMAS AND MODULES USED:

use v5.38;
use strict;
use warnings;
use utf8;
use warnings FATAL => 'utf8';
use Time::HiRes 'time';
use Unicode::Normalize 'NFD';

# ------------------------------------------------------------------------------------------------------------
# START TIMER:
our $t0; BEGIN {$t0 = time}

# ------------------------------------------------------------------------------------------------------------
# SUBROUTINES:

sub strip ($x) {
   return (NFD $x) =~ s/\pM//gr;
}

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:

# Inputs:
my @strings = @ARGV ? eval($ARGV[0]) :
(
   # Example 1 Input:
     'ÃÊÍÒÙ',
   # Expected Output:
   # 'AEIOU'

   # Example 2 Input:
     'âÊíÒÙ',
   # Expected Output:
   # 'aEiOU'
);

# Main loop:
for my $string (@strings) {
   say '';
   say 'Original string: ', $string;
   say 'Stripped string: ', strip $string;
}
exit;

# ------------------------------------------------------------------------------------------------------------
# DETERMINE AND PRINT EXECUTION TIME:
END {my $µs = 1000000 * (time - $t0);printf("\nExecution time was %.0fµs.\n", $µs)}
__END__
