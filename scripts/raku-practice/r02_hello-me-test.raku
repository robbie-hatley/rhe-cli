#!/usr/bin/env raku

#`｢
   We first start by obtaining the user's name,
   before attempting any greeting:
｣
my $name = prompt "Wye, hello there! What is your name? ";

#`{
   Now that we know who we're talking to,
   we can address them by name:
}
say "Hello, $name! Pleased to meet you!";
