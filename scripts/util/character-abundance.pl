#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# abundance.pl
# Prints the abundances of the glyphical (visible) characters in the strings fed to it.
#
# Edit history:
# Sat Sep 18, 2021: Wrote it.
# Sat Sep 18, 2021: Added help.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Tue Oct 03, 2023: Updated to "use v5.36". Got rid of "common::sense". Reduced width from 120 to 110.
# Thu Aug 15, 2024: Deleted unnecessary "use" statements, -C63, moved help() above main.
# Tue Mar 04, 2025: Got rid of prototypes and empty signatures.
##############################################################################################################

use v5.36;
use utf8;

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "character-abundance.pl", Robbie Hatley's nifty program for
   displaying the abundances of glyphical (visible) characters in a file.

   Command line to print this help and exit:
   character-abundance.pl [-h|--help]

   Command line to display abundances of characters in files:
   character-abundance.pl < MyFile.txt

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help ()

my @Fields;
my %Ab;

for (@ARGV) {/^-h$/ || /^--help$/ and help and exit(777)}

while (<>) {
   s/[\s\pC\pZ]//g;                               # Get rid of all non-glyphical characters.
   @Fields = ();                                  # Clear the Fields array for receiving data.
   for my $Field (split //, $_) {                 # Split into individual characters.
      push @Fields, $Field;                       # Push field onto array.
   }
   map {++$Ab{$_}} @Fields;                       # Increment hash elements (autovivify if necessary).
}

for my $key (sort {$Ab{$b}<=>$Ab{$a}} keys %Ab) { # Index hash by reverse order of abundance.
   say "$key => $Ab{$key}";                       # Display how many strings were received for each key.
}
