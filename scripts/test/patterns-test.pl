#!/usr/bin/perl

# "patterns-test.pl"

use v5.32;
use strict;
use warnings;
use utf8;
binmode STDIN,  ":encoding(UTF-8)";
binmode STDOUT, ":encoding(UTF-8)";

our $糨汸趑褫夰 = "Samwood Fredwood Tombert Stevebert";
$糨汸趑褫夰 =~ s/\w+(?=wood\b)/犬/g;
$糨汸趑褫夰 =~ s/\w+(?=bert\b)/猫/g;
$糨汸趑褫夰 =~ s/wood/換/g;
$糨汸趑褫夰 =~ s/bert/湄/g;
say $糨汸趑褫夰;

our $豕觽炷罞蚘 = q(: { } ; / = - & ( ) % @ ~ ` ! [ ] < >);
$豕觽炷罞蚘 =~ s{[!`~]}<owl>g;
$豕觽炷罞蚘 =~ s{[\(\)]}<dog>g;
$豕觽炷罞蚘 =~ s{[<>]}<cat>g;
$豕觽炷罞蚘 =~ s{[\[\]]}<pig>g;
$豕觽炷罞蚘 =~ s{[\{\}]}<cow>g;
$豕觽炷罞蚘 =~ s{[@%&-=/;:]}<finch>g;
say $豕觽炷罞蚘;



# 糨汸趑褫夰
# 豕觽炷罞蚘
# 斑侍駢硙偣
# 絒流浳鎷粘
# 蟙闬湄換埡


