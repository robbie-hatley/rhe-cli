#!/usr/bin/perl
# blat-test.pl
use v5.40;
use utf8::all;
no strict 'refs';
my $Debug = 1;

=pod
This doesn't really work:
sub BLAT :prototype($$) ($STREAM, $string) {
   if ($Debug) {
      say $STREAM $string
   }
   else {
      ; # do nothing
   }
}

BLAT "STDIN", "Hello, world!";
=cut

sub BLAT ($string) {if ($Debug) {say STDERR $string}}


BLAT "Hello, world!";
