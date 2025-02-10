#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# bar-graph.pl
# Prints a percentile bar graph, given a Perl hash.
# Edit history:
#    Tue Nov 09, 2021:
#       Refreshed colophon, title card, and boilerplate.
#       Also fixed some bugs (such as, wrong graph height).
########################################################################################################################

use v5.32;
use utf8;
use experimental 'switch';
use strict;
use warnings;
use warnings FATAL => "utf8";

my $db           = 0  ; # debug?
my $idx          = 0  ; # index for arrays
my $data_string  = '' ; # String to be converted to data hash. (Should be in Perl hash "=>" nomenclature.)
my %data         = () ; # hash of data
my $hash_string  = '' ; # string version of %data, for debugging.
my $datum        = 0  ; # single datum
my @keys         = () ; # array of keys for data
my $count        = 0  ; # count   of non-zero datums
my $average      = 0  ; # average of non-zero datums
my $min          = 0  ; # minimum of datums
my $max          = 0  ; # maximum of datums
my $range        = 0  ; # range   of datums
my $graph_height = 0  ; # height of graph
my $bar_height   = 0  ; # height of a bar on the graph

# Get data:
$data_string = '(' . join('', map {s/\s+$//r;} <>) . ')';
warn "Data string = " . $data_string . "\n" if $db;
%data = eval($data_string);
@keys = sort {$a <=> $b} keys %data;

# If debugging, prin some diagnostics:
if ($db)
{
   warn "\n";
   warn "Hash contents:\n";
   $hash_string = '';
   for my $key (@keys)
   {
      $hash_string .= $key . ' => ' . $data{$key} . ", ";
   }
   $hash_string .= "\n";
   warn $hash_string;
}

# Bail if data isn't a hash with keys 0..99 :
if ( 100 != scalar(@keys) )
{
   die "Error: data must be a hash with keys 0..99\nand values being real numbers.\n$!\n";
}
for ( $idx = 0 ; $idx < 100 ; ++$idx )
{
   if ( $keys[$idx] != $idx )
   {
      die "Error: data must be a hash with keys 0..99\nand values being real numbers.\n$!\n";
   }
}

# Make blank bar graph:
my $blank_string = ' 'x100;
my @strings;
for (0..34) {push @strings, $blank_string}

# Get the average of the NON-ZERO abundances ONLY:
# (Otherwise, sparse data can create divide-by-zero issues.)
for (0..99)
{
   $datum = $data{$_};
   if (0 != $datum)
   {
      ++$count;
      $average += $datum;
   }
}
$average /= $count;

# Get the min, max, and range of the TOTAL data set:
$min = $data{0};
$max = $data{0};
foreach $idx (1..99)
{
   $datum = $data{$idx};
   if ($datum < $min) {$min = $datum;}
   if ($datum > $max) {$max = $datum;}
}
$range = $max - $min;

# Set graph height to the higher of max and (2*average):
$graph_height = 2*$average;
if ($max > 2*$average)
{
   $graph_height = $max;
}

# Print parameters:
say "min = $min";
say "max = $max";
say "avg = $average";
say "rng = $range";
say "hgt = $graph_height";

# Generate graph:
for $idx (0..99)
{
   $datum = $data{$idx};
   $bar_height = int(35*($datum)/$graph_height);
   if ($bar_height <  0) {$bar_height =  0;}
   if ($bar_height > 34) {$bar_height = 34;}
   for my $y (0..$bar_height)
   {
      substr($strings[34-$y], $idx, 1) = '*';
   }
}

# Print graph:
say for @strings;
