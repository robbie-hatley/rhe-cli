#!/usr/bin/perl
use v5.32;
use Carp "cluck";
use Config;
$Config{useithreads} || die "You need thread support to run this";

use threads;

threads->create(sub
{
   my $id = threads->tid;
   foreach (0 .. 10)
			{
      sleep rand 5;
      say "Meow from cat $id ($_)";
   }
})->detach;

for (0 .. 4)
{
   my $t = async
   {
      my $id = threads->tid;
      foreach (0 .. 10)
      {
         sleep rand 5;
         cluck("ARGLE");
         say "Bow wow from dog $id ($_)";
      }
   };
   $t->detach;
   #return $t;
}#;

threads->create("bird")->join;
sub bird
{
   my $id = threads->tid;
   for (0 .. 10)
   {
      sleep rand 5;
      say "Chirp from bird $id ($_)";
   }
}
