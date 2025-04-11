#!/usr/bin/env perl

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# vowel-count.pl
#
# Edit history:
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Thu Nov 25, 2021: Now also printing the "decomposed" version of each string.
# Wed Aug 09, 2023: Upgraded from "v5.32" to "v5.36". Got rid of "common::sense" (antiquated). Reduced width
#                   from 120 to 110. Added strict, warnings, etc, to boilerplate. Now combines all lines into
#                   a single string before counting vowels, and prints only the vowel count, no words.
# Tue Apr 08, 2025: Reduced width from 120 to 110. Simplified shebang to "#!/usr/bin/env perl". Now using CPAN
#                   module "utf8::all" to do all encoding and decoding automatically. Added help. Reduced min
#                   ver from "5.36" to "5.16". Added "-v"/"--verbose" options. Added "sub blat" to print
#                   diagnostics to STDERR only if being verbose.
##############################################################################################################

use v5.16;
use strict;
use warnings;
use utf8::all;
use Unicode::Normalize 'NFD';
use List::Util 'uniq';

my $Verbose = 0; # Be verbose?
for ( my $i = 0 ; $i <= $#ARGV ; ++$i ) {
   local $_ = $ARGV[$i];
   /^-h$/ || /^--help$/
   and print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr) and exit;
   Welcome to "vowel-count.pl", Robbie Hatley's nifty vowel counter. This program
   prints the total number of vowels present in the text which is fed into it via
   STDIN or from files mentioned as command-line arguments. If a -v or --verbose
   option is used, also prints various diagnostic info.
   END_OF_HELP
   /^-v$/ || /^--verbose$/
   and $Verbose = 1
   and splice(@ARGV, $i, 1)
   and --$i;
}

# Print diagnostics to STDERR, only if being verbose:
sub blat {
   my $s = shift;
   $Verbose and say STDERR "$s";
}

# Generate reference string of vowels:
my $raw_v = '';                                      # Variable to hold raw vowels string.
$raw_v .= 'aeiouy';                                  # English vowels.
$raw_v .= 'αεηιοωυῑῡ';                               # Greek   vowels.
$raw_v .= 'ауоыиэяюёе';                              # Russian vowels.
blat "raw       vowel string = $raw_v";              # Print raw vowels string
my $dec_v = NFD $raw_v;                              # Break ext. grp. clstrs. to base letters + diacritics.
my $str_v = $dec_v =~ s/\pM//gr;                     # Erase diacritics from string.
my $fld_v = fc $str_v;                               # Fold case.
my $uni_v = join '', uniq sort split //, $fld_v;     # Sort, then remove adjacent duplicates.
blat "processed vowel string = $uni_v";              # Print processed vowel string.

# Process input stream, comparing it to $uni_v:
my $total = 0;                                       # Initialize total-vowels counter.
while (<>) {                                         # Process each line of input in-turn.
   s/\s+$//;                                         # Chomp endline from string.
   my $letters    = $_ =~ s/[\s\pC\pZ\pN\pP\pS]//gr; # Erase all non-letter characters from string.
   my $decomposed = NFD $letters;                    # Break ext. grp. clstrs. to base letters + diacritics.
   my $stripped   = $decomposed =~ s/\pM//gr;        # Erase diacritics from string.
   my $folded     = fc $stripped;                    # Fold Case.
   my @letters    = split //, $folded;               # get array of base letters (may have duplicates)
   my $vcount     = 0;                               # Initialize vowel counter.
   /[${uni_v}]/ and ++$vcount for @letters;          # Count vowels.
   $total += $vcount;                                # Append count to total.
   blat '';                                          # Print results:
   blat "Original   string = $_";                    # Original string.
   blat "Letters    string = $letters";              # Just the letters.
   blat "Decomposed string = $decomposed";           # Ext. grp. clstrs broken to bases + diacritics.
   blat "Stripped   string = $stripped";             # Diacritics removed.
   blat "Folded     string = $folded";               # Case folded.
   blat "Vowel      count  = $vcount";               # Count of all vowels encountered.
}                                                    # Exit input loop.
blat '';                                             # Print blank line.
say "Total vowels = $total";                         # Announce total number of vowels encountered to STDOUT.
