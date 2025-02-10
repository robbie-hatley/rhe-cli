#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# /rhe/scripts/util/probe.pl
# Probes Perl.
#
# Edit history:
#    Sun Feb 28, 2016 - Wrote it.
#    Sat Apr 16, 2016 - Now using -CSDA.
########################################################################################################################

use v5.32;
use utf8;
use experimental 'switch';
use strict;
use warnings;
use warnings FATAL => "utf8";

use diagnostics -verbose;
use Probe::Perl;

my $p = Probe::Perl->new();

# Version of this perl as a floating point number
say "version = ${\$p->perl_version()}";

# Find a path to the currently-running perl
say "path = ${\$p->find_perl_interpreter()}";

# Get @INC before run-time additions:
$" = "\n";
say "INC paths = \n@{[$p->perl_inc()]}";

# Get the general type of operating system
say "os type = ${\$p->os_type()}";
