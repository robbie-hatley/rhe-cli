#!/usr/bin/perl
# "our-vs-local-test.pl"
use v5.32;
use strict;
use warnings;

our $Fred   = 17;
our $Jeremy = 32;

sub Ralph
{
   our $Fred;
   our $Jeremy;
   state $Albert = 41;
   ++$Albert;
   $Fred += 7;
   $Jeremy += 5;
   {
      local $Fred    = 29463;
      local $Jeremy  = 92345;
      printf("\n");
      printf("state \$Albert = %d\n", $Albert);
      printf("local \$Fred   = %d\n", $Fred  );
      printf("local \$Jeremy = %d\n", $Jeremy);
   }
   printf("our   \$Fred   = %d\n", $Fred  );
   printf("our   \$Jeremy = %d\n", $Jeremy);
}

Ralph;
Ralph;
Ralph;
