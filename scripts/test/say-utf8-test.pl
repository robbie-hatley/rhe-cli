#!/usr/bin/env perl
# say-utf8-test.pl
use v5.00;
use strict;
use warnings;
use warnings FATAL => "utf8";
use utf8;
use utf8::all;

print "Unicode text to STDIO: ÂZ譄ьÕT鯼Dв♄俛♀粨蚍þqù刌Щъ\n";

chdir '/d/test-range/unicode-test';

my $fh;
open $fh, '>', 'Ёщтu♂.txt'
   or warn "Couldn't open file 'Ёщтu♂.txt' for writing.\n$!\n";
print $fh 'WУ堑骐♮гчkн欛☺♃g卤♆Otm慻é'
   or warn "Couldn't print text to file 'Ёщтu♂.txt'.\n$!\n";
close $fh;
print "Text printed to file = \"WУ堑骐♮гчkн欛☺♃g卤♆Otm慻é\"\n";

$fh = undef;
open $fh, '<', 'Ёщтu♂.txt'
   or warn "Couldn't open file 'Ёщтu♂.txt' for reading.\n$!\n";
defined(my $line = <$fh>)
   or warn "Couldn't read text from file 'Ёщтu♂.txt'.\n$!\n";
print "Text read  from file = \"$line\".\n"
   or warn "Couldn't print line.\n$!\n";
print(($line =~ m/WУ堑骐♮гчkн欛☺♃g卤♆Otm慻é/) ? "Matches.\n" : "Doesn't match.\n");
close $fh;
unlink 'Ёщтu♂.txt'
   or warn "Couldn't unlink file 'Ёщтu♂.txt'.\n$!\n";
print "Wow, we actually succeeded!\n";
