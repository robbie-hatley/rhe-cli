#!/usr/bin/perl
# /rhe/scripts/util/angle-unicode-test.pl

use v5.32;
use strict;
use warnings;
use Encode;
use open qw( :encoding(UTF-8) :std );
use warnings FATAL => "utf8";
use utf8;

while(<>)
{
   print $_;
   m/Газманов/
   ? say('Газманов Text Match? YES!')
   : say('Газманов Text Match? NO!') ;
   $_ eq "Олег Газманов русский поэт.\n"
   ? say('Газманов Text Equality? YES!')
   : say('Газманов Text Equality? NO!') ;
   say 'Length of literal = ', length "Олег Газманов русский поэт.\n";
   say 'Length of data    = ', length $_;
}

while(<*>)
{
   $_ = decode 'UTF-8', $_;
   m/Газманов/
   ? say('Газманов File Name Match? YES!')
   : say('Газманов File Name Match? NO!') ;
}

printf("Literal  Oleg Gazmanov: %s\n",    'Олег Газманов');
printf("lwr-case Oleg Gazmanov: %s\n", lc 'Олег Газманов');
printf("UPR-CASE Oleg Gazmanov: %s\n", uc 'Олег Газманов');
printf("fld-case Oleg Gazmanov: %s\n", fc 'Олег Газманов');
printf("translit Oleg Gazmanov: %s\n", 'Олег Газманов' =~ tr/а-яёА-ЯЁ/А-ЯЁа-яё/r);
printf("subst    Oleg Gazmanov: %s\n", 'Олег Газманов' =~ s/азма/амза/r);

=pod

Results of testing this program with NO unicode decoding specified
(lines 8, 9, 10, 11, and 28 commented-out):
Can read uncorrupted lines from line-input operator?  SUCCEED
Can read uncorrupted names from file-glob  operator?  SUCCEED
Can correctly match data using m/// operator?         SUCCEED
Can print literal Unicode data without trouble?       SUCCEED
Correctly determine text equality?                    SUCCEED
Correctly determine string length (# of codepoints)?  FAIL
lc operator works correctly?                          FAIL
uc operator works correctly?                          FAIL
Unicode::CaseFold::fc function works correctly?       FAIL
tr/// transliteration works correctly?                FAIL
Can correctly substitute data using s/// operator?    SUCCEED

Results of testing this program with ALL unicode decoding specified
(lines 8, 9, 10, 11, and 28 re-enabled):
Can read uncorrupted lines from line-input operator?  SUCCEED
Can read uncorrupted names from file-glob  operator?  SUCCEED
Can correctly match data using m/// operator?         SUCCEED
Can print literal Unicode data without trouble?       SUCCEED
Correctly determine text equality?                    SUCCEED
Correctly determine string length (# of codepoints)?  SUCCEED
lc operator works correctly?                          SUCCEED
uc operator works correctly?                          SUCCEED
Unicode::CaseFold::fc function works correctly?       SUCCEED
tr/// transliteration works correctly?                SUCCEED
Can correctly substitute data using s/// operator?    SUCCEED


=cut

