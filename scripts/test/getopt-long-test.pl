#!/usr/bin/env -S perl -C63
use v5.36;
use utf8;
use Getopt::Long;
Getopt::Long::Configure
(
   "no_auto_abbrev",
   "bundling",
   "permute",
   "pass_through"
);
my $Name   = '';  # String: Name
my $Length = 17;  # Number: Length
my $Smarmy = 0;   # Flag:   Smarmy (obsequious)?
my $Frank  = 0;   # Flag:   Frank  (blunt     )?
GetOptions
(
   "n|name=s"    => \$Name,
   "l|length=i"  => \$Length,
   "s|smarmy"    => \$Smarmy,
   "f|frank"     => \$Frank,
);
say "name   = $Name";
say "length = $Length";
say "smarmy = $Smarmy";
say "frank  = $Frank";
say "Remaining elements of \@ARGV are:";
say for @ARGV;
