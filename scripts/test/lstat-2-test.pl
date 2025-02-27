#!/usr/bin/env -S perl -CSDA
# lstat-test.pl
use v5.32;
use utf8;
use Cwd;
use Encode;
use Sys::Binmode;
# STUPID ERROR #1 ON NEXT LINE (CAN YOU SEE IT?):
# (HINT: "DECODE IN, ENCODE OUT")
my $dir = encode_utf8 getcwd;
my $dh  = undef;
opendir($dh, encode_utf8($dir))
or die "Can't open dir!";
# STUPID ERROR #2 ON NEXT LINE (CAN YOU SEE IT?):
# (HINT: SOME THINGS IN PERL NEED "LIST CONTEXT")
foreach my $name (map {decode_utf8($_)} readdir $dh)
{
   lstat(encode_utf8 $name);
   if ( -f _ ) {say "$name is a file.";}
   if ( -d _ ) {say "$name is a directory.";}
}
closedir $dh;
