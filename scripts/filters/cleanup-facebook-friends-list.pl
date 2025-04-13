#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# cleanup-facebook-friends-list.pl
#
# Cleans-up Facebook friends-list "page source" files. (Go to your profile, click "Friends", scroll slowly
# down until friends finish loading but no further, save page as "text", then manually trim the junk at
# beginning and end, leaving "slant,newline,newline,slant,newline" as record separators.) My older ways of
# cleaning-up my Friends lists are obsolete as of 2025 because of changes in Facebook, so I've archived
# those scripts.
#
# Written by Robbie Hatley on Sat Apr 12, 2025.
#
# Edit history:
# Sat Apr 12, 2025: Wrote it.
##############################################################################################################

use v5.16;
use utf8::all;
use List::Util 'uniq';

# Set input record separator to "slant,newline,newline,slant,newline":
$/ = "/\n\n/\n";

# Get raw records:
my @raw;
foreach my $raw (<>) {
   chomp $raw;
   # Fix any split URLs:
   $raw =~ s/(<[^<>\n]+)\n([^<>\n]+>)/$1$2/;
   # Within each raw record, grab first line NOT starting with "<":
   {
      local $/ = "\n";
      my @lines = split /\n/, $raw;
      foreach my $line (@lines) {
         chomp;
         next if $line =~ /^</;
         push @raw, $line;
         last;
      }
   }
}

# Get sorted, deduped version of @raw:
my @sortdup = uniq sort {$a cmp $b} @raw;

# Make list of [name, url] records:
my @records;
my $maxnamlen = 0;
foreach my $item (@sortdup) {
   my ($name, $url);
   if ($item =~ m/ <.+>$/) {
      $name = ( $item =~ s/ <.+>$//r        ) ;
      $url  = ( $item =~ s/^.+(?=<.+>$)//r ) ;
   }
   else {
      $name = $item;
      $url  = '';
   }
   if (length($name)>$maxnamlen) {$maxnamlen=length($name)}
   push @records, [$name, $url];
}

# Print results:
my $width = $maxnamlen + 2;
foreach my $record (@records) {
   my ($name, $url) = @$record;
   printf("%-${width}s%-s\n", $name, $url);
}
