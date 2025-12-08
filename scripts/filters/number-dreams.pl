#!/usr/bin/env perl
# number-dreams.pl
use v5.42;
use utf8::all;
# Initialize a "next line is expected to be dream number" flag to 0:
my $next_is_dream = 0;
# Initialize a "dream number" counter to 1 (so that first dream number will be 1):
my $n = 1;
# Set variable "$_" to each line of STDIN in-turn:
while (<STDIN>) {
   # Chomp BOM (if any) from beginning of $_:
   s/^\N{BOM}//;
   # Chomp newline (if any) from end of $_:
   chomp;
   # If current line is expected to be a "Dream #" line, print the correct dream #:
   if ($next_is_dream) {
      # If current line is dream number:
      if (/^Dream #(\d+)$/) {
         # If the number is correct, just print the line verbatim:
         if ($1 == $n) {
            say;
         }
         # If the number is wrong, print corrected version instead:
         else {
            say "Dream #", $n;
         }
      }
      # Else if current line is NOT dream number, print dream number then print current line:
      else {
         say "Dream #", $n;
         say;
      }
      # Increment dream counter:
      ++$n;
      # Clear "next is dream" flag:
      $next_is_dream = 0;
   }
   # Otherwise if the current line is NOT expected to be a "Dream #" line, just print it verbatim:
   else {
      say;
   }
   # If current line is a string of 49 tildes, set the "next_is_dream" flag:
   if (/^~{49}$/) {
      $next_is_dream = 1;
   }
}
