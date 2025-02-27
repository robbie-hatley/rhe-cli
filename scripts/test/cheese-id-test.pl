#!/usr/bin/perl
use v5.32;
use strict;
use warnings;
no strict "refs";

*{'say "Cheese!";'} =
\"Robbie Hatley Proposes Practical Perl Programs";

say ${'say "Cheese!";'};

*{q<Don't you dare call this subroutine!>} =
sub(){say 'I TOLD YOU NOT TO CALL THIS SUBROUTINE!!!';};

say &{q<Don't you dare call this subroutine!>};
