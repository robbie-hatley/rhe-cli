#!/bin/perl

##############################################################################################################
# mojibake.pl
# Converts STDIN to mojibake.
# Written by Robbie Hatley.
# Edit history:
# Wed May 28, 2025: Wrote it.
##############################################################################################################

# Use this to force the NEED for encoding anything sent to sys-call wrappers,
# but then, DON'T do any encoding:
use Sys::Binmode;
# Set input to "UTF-8" but output to ":raw":
binmode STDIN,  ":raw";
binmode STDOUT, ":utf8";

while (<STDIN>) {
   print "$_";
}
