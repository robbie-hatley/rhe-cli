#!/usr/bin/perl

# handle-variable.pl
# Programming exercise: open a large number of files, hold them open for a while,
# each under a separate file handle, store all file names and file handles,
# print each file handle with corresponding file name, close all files, and exit.

use v5.32;
use strict;
use warnings;

my $i = 0;
my $n = 0;
my $somefile;
my @somefiles;
my @handles;

foreach $somefile (@ARGV)
{
   open($handles[$i], "< :crlf :encoding(cp1252)", $somefile)
      or print("Can't open file ", $somefile, "\n") and next;
   push @somefiles, $somefile;
   ++$i;
   ++$n;
}

print($n, " files are open:\n");

for ($i = 0; $i < $n ; ++$i)
{
   print ($handles[$i], " = ", $somefiles[$i], "\n");
}

# In a real program, we'd do something interesting with the open files here,
# possibly involving comparing their contents.
#
# However, this is not a real program, so we're not going to do that.

for ($i = 0; $i < $n ; ++$i)
{
   close $handles[$i];
}

print("All files are now closed.\n");
