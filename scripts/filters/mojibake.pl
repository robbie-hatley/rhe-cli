#!/bin/perl
##############################################################################################################
# mojibake.pl
# Converts STDIN to mojibake.
# Written by Robbie Hatley.
# Edit history:
# Wed May 28, 2025: Wrote it.
##############################################################################################################
use v5.36;
use Sys::Binmode;        # Force Perl to store text as raw Unicode, not UTF-8.
binmode STDIN,  ":raw";  # Purposely misinterpret UTF-8 as being raw unicode, inbound.
binmode STDOUT, ":utf8"; # Print normally, outbound.

# Replace control codes 0-8, 11-31, 127, 128-159 with safe, visible characters:
sub safe {
   my $forbid = join '', map {chr} (    0 ..    8 ,   11 ..   31 ,  127 ,    128 ..    159 );
   my $replac = join '', map {chr} ( 9216 .. 9224 , 9227 .. 9247 , 9249 , 129792 .. 129823 );
   local $_ = shift;
   eval("tr/$forbid/$replac/");
   return $_;
}

# Use safe mode?
my $Safe = 0;
for (@ARGV) {
   /^--safe$/ || /^-s$/ and $Safe = 1;
}

while (<STDIN>) {
   if ($Safe) {
      my $safe = safe($_);
      print "$safe";
   }
   else {
      print "$_";
   }
}
