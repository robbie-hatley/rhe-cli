#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# wordle-helper-unlimited.pl
# Helps user solve Wordle-style puzzles using various word lengths.
# Written by Robbie Hatley.
# Edit history:
# Tue Aug 25, 2026: Wrote it.
# Wed Aug 26, 2026: Split into simple and unlimited versions.
##############################################################################################################

use v5.36;             # To get signatures.
use utf8::all;         # Use UTF-8 for everything.
use List::Util 'uniq'; # Nix dups.

# ======= VARIABLES: =========================================================================================

# ------- System Variables: ----------------------------------------------------------------------------------

$" = ', ' ; # Quoted -array element separator = ", ".

# ------- Local variables: -----------------------------------------------------------------------------------

# Settings:    Default:       Meaning of setting:
my @Opts     = ()         ; # options
my @Args     = ()         ; # arguments
my $Help     = 0          ; # Just print help and exit?
my $wl       = 5          ; # Word length.
my $kl       = ''         ; # Known (green) letters (string form).
my @kl       = ()         ; # Known (green) letters (array  form).
my $pd       = ''         ; # Positionally-Disallowed letters (string form).
my @pd       = ()         ; # Positionally-Disallowed letters (array  form).
my @mh       = ()         ; # Must-Have letters.
my $gd       = ''         ; # Globally-Disallowed (gray) letters (string form).
my @gd       = ()         ; # Globally-Disallowed (gray) letters (array  form).

# Word lists:  Default:       Meaning of list:
my @words    = ()         ; # Most English words of length $wl.
my @known    = ()         ; # Words which have all of the known letters
my @posit    = ()         ; # Words which also have no positionally-disallowed letters.
my @musth    = ()         ; # Words which also do have all must-have letters.
my @cands    = ()         ; # Words which also do not have any globally-disallowed letters.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub help    ; # Print help and exit.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Process @ARGV and set settings:
   argv;

   # If user wants help, just print help and exit:
   if ($Help) {help; exit;}

   # Announce word length:
   say "Word length: $wl";

   # Die if word length is not an integer from 1 through 28:
   if ( $wl !~ m/^[1-9][0-9]*$/ || $wl < 1 || $wl > 28 ) {
      die "Error: Word length must be a positive integer 1-28.\n";
   }

   # Array of known letters defaults to a list of $wl empty strings:
   @kl = ('')x$wl;

   # If $kl is not an empty string, get @kl from $kl:
   if ( 0 != length $kl ) {
      @kl = split ',', $kl, -1;
   }

   # Announce known letters:
   say 'known letters                   = (' . (join ', ', (map {"'".$_."'"} @kl)) . ')' ;

   # Die if number-of-elements of @kl is not $wl:
   if ( scalar(@kl) != $wl ) {
      die "Error: Wrong number of known letters.\n";
   }

   # Array of positionally-disallowed letters defaults to a list of $wl empty strings:
   @pd = ('')x$wl;

   # If $pd is not an empty string, get @pd from $pd:
   if ( 0 != length $pd ) {
      @pd = split ',', $pd, -1;
   }

   # Announce positionally-disallowed letters:
   say 'Positionally-Disallowed letters = (' . (join ', ', (map {"'".$_."'"} @pd)) . ')' ;

   # Die if number-of-elements of @pd is not $wl:
   if ( scalar(@pd) != $wl ) {
      die "Error: Wrong number of positionally-disallowed letter clusters.\n";
   }

   # Get Must-Have letters from Positionally-Disallowed letters:
   @mh = uniq sort map {split //, $_} @pd;

   # Announce the must-have letters:
   say 'Must-Have letters               = (' . (join ', ', (map {"'".$_."'"} @mh)) . ')' ;

   # Array of globally-disallowed letters defaults to an empty list:
   @gd = ();

   # If string $gd is not empty, set @gd to a split of that string:
   if ( length($gd) > 0 ) {
      @gd = split //, $gd;
   }

   # Announce globally-disallowed letters:
   say 'Globally-Disallowed letters     = (' . (join ', ', (map {"'".$_."'"} @gd)) . ')' ;

   # Get a list of most English words of length $wl from file "words-large.txt":
   my $path= __FILE__ =~ s#/[^/]+$#/#r;
   open FH, '<', $path.'words-large.txt'
   or die "Error: Couldn't open file \"words-large.txt\".\n$!\n";
   foreach my $line (<FH>) {
      chomp $line;
      next if length($line) != $wl;
      push @words, $line;
   }
   close FH;

   # Obtain list of words containing known letters:
   WORD: foreach my $word (@words) {
      POSITION: for ( my $i = 0 ; $i < $wl ; ++$i ) {
         next POSITION if 0 == length $kl[$i];
         next WORD     if $kl[$i] ne '' && substr($word, $i, 1) ne $kl[$i];
      }
      push @known, $word;
   }
   #say "Known      = (@known)";

   # Obtain list of words not containing positional disallowances:
   WORD: foreach my $word (@known) {
      POSITION: for ( my $i = 0 ; $i < $wl ; ++$i ) {
         next POSITION if 0 == length $pd[$i];
         next WORD     if substr($word, $i, 1) =~ m/[$pd[$i]]/;
      }
      push @posit, $word;
   }
   #say "Posit      = (@posit)";

   # Obtain list of words containing "must-have" letters:
   WORD: foreach my $word (@posit) {
      LETTER: foreach my $letter (@mh) {
         next WORD if $word !~ m/$letter/;
      }
      push @musth, $word;
   }
   #say "Musth      = (@musth)";

   # Obtain list of words not containing globally-disallowed letters:
   WORD: foreach my $word (@musth) {
      LETTER: foreach my $letter (@gd) {
         next WORD if $word =~ m/$letter/;
      }
      push @cands, $word;
   }
   say "Candidates = (@cands)";

   # Exit program, returning success code "0" to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV:
sub argv {
   # Get options and arguments:
   for ( @ARGV ) {
      if   (/^-/) {push @Opts, $_;}
      else        {push @Args, $_;}
   }
   # Process options:
   for ( @Opts ) {
      /^-h$/ || /^--help$/ and $Help = 1  ;
      /^--wl=(.+)$/        and $wl   = $1 ;
      /^--kl=(.+)$/        and $kl   = $1 ;
      /^--pd=(.+)$/        and $pd   = $1 ;
      /^--gd=(.+)$/        and $gd   = $1 ;
   }
   # Ignore all other options.
   # Ignore all arguments.
   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Print help:
sub help {
   print STDERR ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "wordle-helper-unlimited.pl". This program helps users solve
   Wordle and other Wordle-style puzzles using word lengths from 1 through 28,
   by providing the most-likely candidates given available information.

   -------------------------------------------------------------------------------
   Command lines:

   wordle-helper-unlimited.pl  -h | --help  (to print this help and exit)
   wordle-helper-unlimited.pl  [options]    (to help solve Wordle puzzles)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:        Meaning:
   -h or --help   Print help and exit.
   --wl=7         Word length (from 1-28, defaulting to 5).
   --kl=s,,,,     Known (green) letters.
   --pd=,,eo,,t   Positionally-Disallowed (yellow) letters.
   --gd=loanpidr  Globally-Disallowed (gray) letters.

   Any options not listed above will be ignored.

   The "word length", if specified, must be an integer between 1 and 28 inclusive.
   If not specified, this defaults to 5.

   The "known" letters are the green letters in Wordle. These must be a space-free
   string of comma-separated substrings, such as "s,,,," which means "The first
   letter must be 's'.".
   The number of commas must be one-less-than the word length.
   If not specified, this defaults to none.

   The "positionally-disallowed" letters are the yellow letters in Wordle. These
   must be a space-free string of comma-separated substrings, such as ",,eo,t,"
   which means "the third letter must not be e or o and the fourth letter must not
   be t, but e and o and t must be present in the word".
   The number of commas must be one-less-than the word length.
   If not specified, this defaults to none.

   The "globally-disallowed" letters are the gray letters in Wordle (OTHER THAN
   disallowances of duplicate letters). These must be clumped together as a single
   space-free string of unique letters, such as "owpqr".
   If not specified, this defaults to none.

   -------------------------------------------------------------------------------
   Description of Arguments:

   Any non-option arguments will be ignored.


   Happy Wordle solving!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
