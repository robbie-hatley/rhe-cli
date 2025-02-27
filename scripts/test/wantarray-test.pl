#!/usr/bin/perl

use v5.32;
use strict;
use warnings;

sub void_context;
sub scalar_context;
sub list_context;

@::List = ('apple', 'pear', 'peach', 'plum', 'banana', 'mango', 'kiwi');
say "@::List";

say 'argle';
my $retval = wantarray;
if    (not defined $retval) {say "main undef"; }
elsif (            $retval) {say "main true" ; }
elsif (      !     $retval) {say "main false"; }

void_context($::List);
my $scalar_var = scalar_context(@::List);
say "Scalar return value = $scalar_var";
my @array_var = list_context(@::List);
say "List return value = @array_var";

exit 0;

sub void_context {
   say "bargle";
   my $retval = wantarray;
   if    (not defined $retval) {say "void undef"; return 1;}
   elsif (            $retval) {say "void true" ; return @_;}
   elsif (      !     $retval) {say "void false"; return scalar(@_);}
}

sub scalar_context {
   say "fargle";
   my $retval = wantarray;
   if    (not defined $retval) {say "scalar undef"; return 1;}
   elsif (            $retval) {say "scalar true" ; return @_;}
   elsif (      !     $retval) {say "scalar false"; return scalar(@_);}
}

sub list_context {
   say "gargle";
   my $retval = wantarray;
   if    (not defined $retval) {say "list undef"; return 1;}
   elsif (            $retval) {say "list true" ; return @_;}
   elsif (      !     $retval) {say "list false"; return scalar(@_);}
}







