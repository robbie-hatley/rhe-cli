#!/usr/bin/perl
use v5.32;
use strict;
use warnings;
$_ = q(   fRED diDN't-eaT+SEven burn't cHeEsE+saNdwicHes);
s/(?<!')(\pL+)/\u\L$1/g;
say;
