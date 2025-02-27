#!/usr/bin/env -S perl -CSDA
# /rhe/scripts/util/rnf-test.pl
use v5.32;
use strict;
use warnings;
use warnings FATAL => "utf8";
use utf8;

# (Elide many lines here for brevity.)

print <<'END_OF_HELP';
Welcome to "Renamefiles", Robbie Hatley's file-renaming Perl script.
(Elide many lines here for brevity.)
Example command line:
rnf -r '([[:alpha:]]{3})(\d{3})' '$1-$2'
(would rename "sjx387.txt" to "sjx-387.txt")
(Elide many lines here for brevity.)
END_OF_HELP

exit 0;
