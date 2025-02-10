#!/usr/bin/env -S perl -CSDA

=pod

--------------------------------------------------------------------------------------------------------------
COLOPHON:
This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。麦藁雪、富士川町、山梨県。

--------------------------------------------------------------------------------------------------------------
TITLE BLOCK:
Solutions in Perl for The Weekly Challenge 236-1.
Written by Robbie Hatley on Fri Oct 06, 2023.

--------------------------------------------------------------------------------------------------------------
PROBLEM DESCRIPTION:
Task 1: Exact Change
Submitted by: Mohammad S Anwar
You are asked to sell juice. Each costs $5. You are presented with
an array containing only $5 and/or $10 and/or $20 bills. Each bill
is owned by one customer, and the customers are to be served in
left-to-right order. You are allowed to sell only one juice to
each customer, and only if you can provide exact change. You do
not have any cash in your till to begin with. Write a script to
find out if it is possible to give exact change to all customers.

Example 1:
Input: @bills = (5, 5, 5, 10, 20)
Output: true
From the first 3 customers, we collect three $5 bills in order.
From the fourth customer, we collect a $10 bill and give back a $5.
From the fifth customer, we give a $10 bill and a $5 bill.
Since all customers got correct change, we output true.

Example 2:
Input: @bills = (5, 5, 10, 10, 20)
Output: false
From the first two customers in order, we collect two $5 bills.
For the next two customers in order, we collect a $10 bill and give back a $5 bill.
For the last customer, we can not give the change of $15 back because we only have two $10 bills.
Since not every customer received the correct change, the answer is false.

Example 3:
Input: @bills = (5, 5, 5, 20)
Output: true

--------------------------------------------------------------------------------------------------------------
PROBLEM NOTES:
Since ability to give change is determined by what's in the till, I'll start by making an array "@arrays" to
hold multiple input "@bills" arrays, then for each "@bills" array I'll make a "@till" array that starts-off
empty. For each "$bill" in "@bills", I'll push "$bill" to "@till", set "$change" to "$bill-5", and see if I
can get "$change" down to 0 by subtracting bills from till. If I can get "$change" down to 0 for all customers
I'll return "true" else "false".

--------------------------------------------------------------------------------------------------------------
IO NOTES:
Input is via either built-in variables or via @ARGV. If using @ARGV, provide one argument which must be a
single-quoted array of arrays of integers, in proper Perl syntax, like so:
./ch-1.pl '([20,20,20],[5,5,10,20])'

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

# ------------------------------------------------------------------------------------------------------------
# START TIMER:
our $t0; BEGIN {$t0 = time}

# ------------------------------------------------------------------------------------------------------------
# MAIN BODY OF PROGRAM:

# Inputs:
my @arrays = @ARGV ? eval($ARGV[0]) :
(
   [5, 5, 5, 10, 20],
   [5, 5, 10, 10, 20],
   [5, 5, 5, 20],
);

# Main loop:
for my $bref (@arrays) {                         # For each reference to an incoming bill stream:
   my @bills = @$bref;                           # Stream of incoming bills, one bill per customer.
   my @till  = ();                               # Bills in till available to be handed back as change.
   my $sac   = 'True!';                          # Start with "Satisfied All Customers" set to 'True!'.
   foreach my $bill (@bills) {                   # For each customer:
      push @till, $bill;                         # Take customer's money.
      @till = sort {$b <=> $a} @till;            # Organize your till in descending order.
      my $change = $bill-5;                      # Give customer a juice; you now owe him/her $bill-5.
      for ( my $i = 0 ; $i <= $#till ; ++$i ) {  # For each bill in till, starting with biggest:
         last if 0 == $change;                   # Stop trying to make change if our debt is 0.
         if ( $till[$i] <= $change ) {           # If we owe customer at least this much money,
            $change -= $till[$i];                # reduce our debt to customer
            splice @till, $i, 1;                 # by handing him this bill,
            --$i; } }                            # and shift all remaining bills one leftward.
      if ( 0 != $change ) {                      # If we were NOT able to make change for current customer,
         $sac = 'False!';                        # set "Satisfied All Customers" to 'false'
         last; } }                               # and stop selling juice.
   say '';
   say 'Bills from customers = (' . join(', ', @bills) . ')';
   say 'Were we able to make change for all customers? ' . $sac; }
exit;

# ------------------------------------------------------------------------------------------------------------
# DETERMINE AND PRINT EXECUTION TIME:
END {
   my $µs = 1000000 * (time - $t0);
   printf("\nExecution time was %.0fµs.\n", $µs);
}
__END__
