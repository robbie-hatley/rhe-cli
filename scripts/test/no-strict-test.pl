#!/usr/bin/perl
# "no-strict-test.pl"
use v5.32;
no strict;
use warnings;

$Fred   = 17;
$Jeremy = 32;
sub Ralph
{
   state $Albert = 41;
   ++$Albert;
   printf("\$Albert = %d\n", $Albert);
   $Fred   += 7;
   $Jeremy += 5;
}

printf("\$Fred   = %d\n", $Fred  );
printf("\$Jeremy = %d\n", $Jeremy);
printf("\n");

Ralph;
printf("\$Fred   = %d\n", $Fred  );
printf("\$Jeremy = %d\n", $Jeremy);
printf("\n");

Ralph;
printf("\$Fred   = %d\n", $Fred  );
printf("\$Jeremy = %d\n", $Jeremy);
printf("\n");

Ralph;
printf("\$Fred   = %d\n", $Fred  );
printf("\$Jeremy = %d\n", $Jeremy);
printf("\n");

printf("\$Albert = %d\n", $Albert);
