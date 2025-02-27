#!/usr/bin/perl
# "zeros-ones.pl"
use strict;
use warnings;

our $string = $ARGV[0];
our $last_idx = length($string) - 1;
our $cur_char = '';
our $prv_char = '';
our $cur_zer_cnt = 0;
our $max_zer_cnt = 0;
our $cur_one_cnt = 0;
our $max_one_cnt = 0;
our $cur_oth_cnt = 0;
our $max_oth_cnt = 0;

for ( 0 ..  $last_idx)
{
   $cur_char = substr($string, $_, 1);

   if ($cur_char eq '0')
   {
      if ($prv_char eq '0')
      {
         ++$cur_zer_cnt;
      }
      elsif ($prv_char eq '1')
      {
         $max_one_cnt = $cur_one_cnt if $cur_one_cnt > $max_one_cnt;
         $cur_one_cnt = 0;
         $cur_zer_cnt = 1;
      }
      else
      {
         $max_oth_cnt = $cur_oth_cnt if $cur_oth_cnt > $max_oth_cnt;
         $cur_oth_cnt = 0;
         $cur_zer_cnt = 1;
      }
   }

   elsif ($cur_char eq '1')
   {
      if ($prv_char eq '0')
      {
         $max_zer_cnt = $cur_zer_cnt if $cur_zer_cnt > $max_zer_cnt;
         $cur_zer_cnt = 0;
         $cur_one_cnt = 1;
      }
      elsif ($prv_char eq '1')
      {
         ++$cur_one_cnt;
      }
      else
      {
         $max_oth_cnt = $cur_oth_cnt if $cur_oth_cnt > $max_oth_cnt;
         $cur_oth_cnt = 0;
         $cur_one_cnt = 1;
      }
   }

   else # "other"
   {
      if ($prv_char eq '0')
      {
         $max_zer_cnt = $cur_zer_cnt if $cur_zer_cnt > $max_zer_cnt;
         $cur_zer_cnt = 0;
         $cur_oth_cnt = 1;
      }
      elsif ($prv_char eq '1')
      {
         $max_one_cnt = $cur_one_cnt if $cur_one_cnt > $max_one_cnt;
         $cur_one_cnt = 0;
         $cur_oth_cnt = 1;
      }
      else
      {
         ++$cur_oth_cnt;
      }
   }
   $prv_char = $cur_char;
}
$max_zer_cnt = $cur_zer_cnt if $cur_zer_cnt > $max_zer_cnt;
$max_one_cnt = $cur_one_cnt if $cur_one_cnt > $max_one_cnt;
$max_oth_cnt = $cur_oth_cnt if $cur_oth_cnt > $max_oth_cnt;
print "Max zeros count = ", $max_zer_cnt, "\n";
print "Max ones  count = ", $max_one_cnt, "\n";
print "Max other count = ", $max_oth_cnt, "\n";
