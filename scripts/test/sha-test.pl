#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file.
# ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# sha-test.pl
# Tests the "Digest::SHA" module.
#
# Edit history:
#    Thu Jan 14, 2012: Wrote it.
########################################################################################################################

use v5.32;
use strict;
use warnings;
use experimental 'switch';
use utf8;
use warnings FATAL => "utf8";

use Digest::SHA qw(sha256_hex);

use RH::Dir;

my $data = "hello world";
say "\$data = $data";
my @frags = split(//, $data);
say "\@frags = @frags";

# all-at-once (Functional style)
my $digest1 = sha256_hex($data);
say "\$digest1 = $digest1";

# in-stages (OOP style)
my $state = Digest::SHA->new(256);
for (@frags) { $state->add($_) }
my $digest2 = $state->hexdigest;
say "\$digest2 = $digest2";

print $digest1 eq $digest2 ? "whew!\n" : "oops!\n";
