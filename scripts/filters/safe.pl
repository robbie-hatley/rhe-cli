#!/usr/bin/env perl
# safe.pl
# Converts any dangerous and/or invisible control codes into safe-and-visible characters.
use utf8::all;

# Replace control codes 0-8, 11-31, 127, 128-159 with safe, visible characters:
my $forbid = join '', map {chr} (    0 ..    8 ,   11 ..   31 ,  127 ,    128 ..    159 );
my $replac = join '', map {chr} ( 9216 .. 9224 , 9227 .. 9247 , 9249 , 129792 .. 129823 );
sub safe {
   local $_ = shift;
   eval("tr/$forbid/$replac/");
   return $_;
}

# Print safe version of input to output:
print safe(join '', <>);
