#!/usr/bin/perl
# quest.pl

use v5.36;

my @HighestMountains = ( 'Mount Everest', 'K2', 'Mount McKinley', 'Mount Shasta' );
my $ThroughTheFields = 'Fields Of Gold';
my $CityWalls        = 'El Pueblo de Nuestra Señora la Reina de los Ángeles del Río de Porciúncula';
my @ToBeWithYou      = qw( Fredrick Gregory Brianna );
my @WhatImLookingFor = qw( Love Peace Power Prosperity );

sub climb (@heights) {
   my $number = scalar(@heights);
   my $index  = int rand $number;
   my $choice = $heights[$index];
   say "I climbed $choice.";
}

sub run {
   if ( scalar(@_) > 0 ) {say "I ran through ${_}." for @_ }
}

sub crawl {
   say 'I crawled across The Mojave Desert.';
}

sub scale {
   if ( @_ ) {say "I scaled the city walls of \"$_\"." for @_ }
   else      {say "I scaled city walls."                      }
}

sub only (@list) {
   my $number = scalar(@list);
   my $index  = int rand $number;
   my $choice = $list[$index];
   say "I only want to be with $choice.";
}

sub moonshadow {
   say "I'm being followed by a moon shadow.";
}

sub find (@needful_things) {
   my $found = 0;
   foreach my $needful_thing (@needful_things) {
      foreach my $item (@ARGV) {
         if ( $item =~ m/$needful_thing/i ) {
            say "I found $item!";
            $found = 1;
         }
      }
   }
   return $found;
}

sub quest {
   climb @HighestMountains;
   run $ThroughTheFields;
   run, crawl, scale $CityWalls;
   only @ToBeWithYou;
   moonshadow;
   find(@WhatImLookingFor)
   or say "But I still haven't found what I'm looking for!"
}

# Let's go on a quest:
quest
