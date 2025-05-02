#!/usr/bin/env perl

=pod

--------------------------------------------------------------------------------------------------------------
TITLE AND ATTRIBUTION:
Solutions in Perl for The Weekly Challenge 286-1,
written by Robbie Hatley on Sun Sep 08, 2024.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 286-1: Self Spammer
Submitted by: David Ferrone

Write a program which outputs one word of its own script
source code at random. A word is anything between whitespace,
including symbols.

Example 1:
If the source code contains a line such as:
'open my $fh, "<", "ch-1.pl" or die;'
then the program would output each of the words
{ open, my, $fh,, "<",, "ch-1.pl", or, die; }
(along with other words in the source) with some
positive probability.

Example 2:
Technically 'print(" hello ");' is *not* an example program,
because it does not assign positive probability to the other
two words in the script. It will never display print(" or ").

Example 3:
An empty script is one trivial solution, and here is another:
echo "42" > ch-1.pl && perl -p -e '' ch-1.pl

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
I'll use this approach:
1. Undefine variable "$/" to turn on whole-file slurping.
2. Open file at path "$0" (that is, my program will open its own source code).
3. Slurp the contents of the source into into scalar "$source".
4. Lex the tokens of $source to @tokens using "my @tokens = split /\s+/, $source;".
5. Print one of those tokens at-random: 'my $token = $tokens[int rand scalar @tokens]; print "$token\n";'

--------------------------------------------------------------------------------------------------------------
IO NOTES:
The only input is this script itself.

Output is to STDOUT and will be one token from this script.

=cut

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:
$/ = undef;
my $fh = undef;
open $fh, "<", "$0";
my @source = <$fh>;
my @tokens = split /\s+/, $source[0];
my $token = $tokens[int rand scalar @tokens];
print "$token\n";
