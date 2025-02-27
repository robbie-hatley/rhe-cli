#!/usr/bin/env -S perl -CSDA
# say-utf8-test.pl
use v5.32;
use strict;
use warnings;
use utf8;
use warnings FATAL => "utf8";

use Encode;

use RH::Dir;

say('Unicode text to STDIO: ÂZ譄ьÕT鯼Dв♄俛♀粨蚍þqù刌Щъ')
   or warn "Couldn't print line to STDOUT.\n$!\n";

chdir_utf8 '/D/test-range/unicode-test'
   or die "Couldn't cd to test range.\n$!\n";

my $fh;
open_utf8($fh, '>', 'Ёщтu♂.txt')
   or die "Couldn't open file 'Ёщтu♂.txt' for writing.\n$!\n";
say($fh 'Unicode text to/from file: WУ堑骐♮гчkн欛☺♃g卤♆Otm慻é')
   or warn "Couldn't print line to file 'Ёщтu♂.txt'.\n$!\n";
close $fh;

$fh = undef;
open_utf8 $fh, '<', 'Ёщтu♂.txt'
   or die "Couldn't open file 'Ёщтu♂.txt' for reading.\n$!\n";
defined(my $line = <$fh>)
   or warn "Couldn't read line from file 'Ёщтu♂.txt'.\n$!\n";
print $line
   or warn "Couldn't print line.\n$!\n";
say $line =~ m/欛/ ? "Matches 欛." : "Doesn't match 欛.";
say $line =~ m/譄/ ? "Matches 譄." : "Doesn't match 譄.";
close $fh;
unlink_utf8 'Ёщтu♂.txt'
   or warn "Couldn't unlink file 'Ёщтu♂.txt'.\n$!\n";
say("Wow, we actually succeeded!");
