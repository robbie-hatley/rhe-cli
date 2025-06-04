#!/usr/bin/env perl
# plasmarc-split.pl
use v5.36;
use utf8::all;
my $user  = getlogin;
my @lines = ();
my @pics  = ();
open FH, '<', "/home/$user/.config/plasmarc" or die "Couldn't open \"plasmarc\"!\n";
while(<FH>) {
   next if /^\[Theme\]$/;
   next if /^name=default$/;
   next if /^$/;
   push @lines, $_;
}
close FH;
for ( my $idx = 0 ; $idx <= $#lines ; ++$idx ) {
   if ( $lines[$idx] =~ m#^usersWallpapers=# ) {
      @pics = split ",", $lines[1];
      $pics[0] =~ s#^usersWallpapers=##;
      last;
   }
}
for my $pic (@pics) {say $pic}
