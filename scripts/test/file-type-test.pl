#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file.
# ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

# file-type-test.pl

use v5.32;
use strict;
use warnings;
use warnings FATAL => "utf8";
use utf8;

use File::Type;

use RH::Util;
use RH::Dir;

my $file   = '/sl/hzpcgdzq.jpg';
my $typer  = File::Type->new();
my $type   = $typer->checktype_filename($file);

say $type;
