#!/usr/bin/env -S perl -CSDA
use v5.32;
say s/cat/dog/r =~ tr/aeiou/eioua/r =~ s/\n//r for <>;
