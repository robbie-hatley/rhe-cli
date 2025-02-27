#!/usr/bin/perl
use v5.32;
use strict;
use warnings;
no  warnings qw( qw );
use utf8;
use open qw( :encoding(utf8) :std );
use charnames qw(:full);

our @marks = qw( ` ~ ! @ # $ % ^ & * \( \) - _ = + [ ] { } \\ | ; : ' " < > , . ? / );

printf("Found %d marks:\n", scalar(@marks));
foreach my $mark (@marks)
{
   my $PrlWrd = ( $mark =~ m/\w/          ) ? 'yes' : 'no' ;
   my $PosPun = ( $mark =~ m/[[:punct:]]/ ) ? 'yes' : 'no' ;
   my $UniPun = ( $mark =~ m/\pP/         ) ? 'yes' : 'no' ;
   my $UniSym = ( $mark =~ m/\pS/         ) ? 'yes' : 'no' ;
   printf("Mark: %1s   PrlWrd? %-3s   PosPun? %-3s   UniPun? %-3s   UniSym? %-3s\n",
           $mark, $PrlWrd, $PosPun, $UniPun, $UniSym);
}
