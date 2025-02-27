#!/usr/bin/perl
# /rhe/scripts/util/Template.pl
# ¡España! Олег Газманов русский поэт. Þórinn Eikinskjaldi. 麦藁雪、富士川町、山梨県。

use v5.32;
use strict;
use warnings;
use Encode;
use Unicode::Normalize qw( NFD NFC );
use Unicode::CaseFold;
use RH::Dir;
use RH::Util;
use open qw( :encoding(UTF-8) :std );
use warnings FATAL => "utf8";
use utf8;

if ( (fc NFD 'Олег Газманов') eq (fc NFD 'олег газманов') )
{
   say "COWABUNGA!";
}

else
{
   say "FUCK.";
}

if ( (fc NFD 'Олег Газманов') eq (fc NFD 'Олег Гамзанов') )
{
   say "DAMN.";
}

else
{
   say "DIFFERENT!";
}

say fc NFD 'Олег Газманов';
say fc NFD 'олег газманов';
say fc NFD 'Олег Гамзанов';
say fc NFD 'олег гамзанов';

