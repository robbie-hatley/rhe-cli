#!/usr/bin/perl
use v5.36;
use Scalar::Util 'looks_like_number';
my $name;
my $number;
my %scores;
my $top_nam = '';
my $top_sco = 0;
my $btm_nam = '';
my $btm_sco = 100;
while(<>){
   ($name, $number) = split /\s+/, $_;
   if (looks_like_number($name))
      {die "out of sync (got number when expecting name)"}
   if (!looks_like_number($number))
      {die "out of sync (got name when expecting number)"}
   $scores{$name} = $number;}
for (keys %scores){
   if ($scores{$_} > $top_sco){
      $top_nam = $_;
      $top_sco = $scores{$_};}
   if ($scores{$_} < $btm_sco){
      $btm_nam = $_;
      $btm_sco = $scores{$_};}}
say "Students' scores are as follows:";
say '';
say "$_ $scores{$_}" for (keys %scores);
say '';
say "Top student is $top_nam who scored $top_sco.";
say "Bottom student is $btm_nam who scored $btm_sco because he didn't do his homework.";
