#!/usr/bin/perl

# undef-test.pl

use v5.32;
use strict;
use warnings;

my $filename;
my $filehandle;
my $buffer         = "asdf";
my $read_result    = 18;
my $indirect       = 42;

$filename = "undef-test.pl";
open($filehandle, "<", $filename); # Should succeed if cwd is location of THIS file.

$filename = "fzgnwmqp.txt";
open($filehandle, "<", $filename); # Fails (unless "fzgnwmqp.txt" exists in cur dir).

$read_result = read($filehandle, $buffer, 1048576); # Fails.
$indirect    = $read_result;

if (defined $filehandle)
{
   say "\$filehandle defined";
   say "\$filehandle = $filehandle";
}
else
{
   say "\$filehandle undefined";
}

if (defined $read_result)
{
   say "\$read_result defined";
   say "\$read_result = $read_result";
}
else
{
   say "\$read_result undefined";
}

if (defined $indirect)
{
   say "\$indirect defined";
   say "\$indirect = $indirect";
}
else
{
   say "\$indirect undefined";
}

exit 0;
