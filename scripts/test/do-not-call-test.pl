#!/usr/bin/perl
use v5.32;
no strict "refs";
no strict "subs";

*{q<Don't you dare call this subroutine!>} =
   sub(){say 'I TOLD YOU NOT TO CALL THIS SUBROUTINE!!!';};
say ( &{q<Don't you dare call this subroutine!>} );
