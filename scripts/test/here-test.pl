#!/usr/bin/perl
use v5.32;
use strict;
use warnings;

# Store "here document" in a variable:
my $a = <<'aarg';
Once upon a time there was a little dog named Sam.
Sam's bark was bigger than his bite. Sam tried to
be intimidting, but peopled either ignored him or
kicke him around. Until one day when Sam got super
pissed and bit the mail man's head off.
aarg
print $a;

# Execute commands:
my $b = <<`EOC`;
echo hi there
echo lo there
EOC
print $b;

# You can stack them:
print <<"dromedary", <<"camelid";
I said bactrian.
dromedary
She said llama.
camelid
