#!/usr/bin/env perl
# number-dreams.pl
use v5.42;
use utf8::all;
my $next_is_dream = 0;
my $n = 1;
while (<STDIN>) {
   # Get rid of BOM (if any):
   s/^\N{BOM}//;
   # Get rid of newline:
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
