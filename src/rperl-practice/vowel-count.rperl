use strict;
use warnings;
our $VERSION = 5.36;
use utf8;

use Unicode::Normalize 'NFD';
use List::Util 'uniq';

# Generate reference string of vowels:
my $raw_v;                                           # Variable to hold raw vowels string.
$raw_v .= 'aeiouy';                                  # English
$raw_v .= 'αεηιοωυῑῡ';                               # Greek
$raw_v .= 'ауоыиэяюёе';                              # Russian
print "raw       vowel string = $raw_v\n";           # Raw.
my $dec_v = NFD $raw_v;                              # Decomposed.
my $str_v = $dec_v =~ s/\pM//gr;                     # Stripped.
my $fld_v = fc $str_v;                               # Folded.
my $uni_v = join '', uniq sort split //, $fld_v;     # Unique.
print "processed vowel string = $uni_v\n";           # Processed.

# Process input stream, comparing it to $uni_v:
while (<>) {
   s/\s+$//;                                         # Chomp endline from string.
   my $letters    = $_ =~ s/[\s\pC\pZ\pN\pP\pS]//gr; # Erase all non-letter characters from string.
   my $decomposed = NFD $letters;                    # Break ext. grp. clstrs. to base letters + diacritics.
   my $stripped   = $decomposed =~ s/\pM//gr;        # Erase Marks from string.
   my $folded     = fc $stripped;                    # Fold Case.
   my @letters    = split //, $folded;               # get array of base letters (may have duplicates)
   my $vcount     = 0;                               # Initialize vowel counter.
   /[${uni_v}]/ and ++$vcount for @letters;          # Count vowels.
   print "\n";                                       # Print results:
   print "Original   string = $_\n";                 # Original string.
   print "Letters    string = $letters\n";           # Just the letters.
   print "Decomposed string = $decomposed\n";        # Ext. grp. clstrs broken to bases + diacritics.
   print "Stripped   string = $stripped\n";          # Diacritics removed.
   print "Folded     string = $folded\n";            # Case folded.
   print "Vowel      count  = $vcount\n";            # Count of all vowels encountered.
}
