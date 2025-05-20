#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# words-by-length.pl
# Prints the unique words of its input, in increasing order of length.
#
# Edit history:
# Sat May 17, 2025: Wrote it.
##############################################################################################################

# Modules and subs:
use v5.36;
use utf8::all;
use List::Util 'uniq';

# Settings:
my $Debug = 0;
my $Help  = 0;

# Subroutine predeclarations:
sub BLAT;
sub argv;
sub help;

# Main body of program:
{                                                        # Begin main body of program.
   argv;                                                 # Process command-line arguments.
   $Help and help and exit 777;                          # If user wants help, just print help and exit.
   my @words;                                            # Words array.
   for my $line ( <> ) {                                 # Process input line-by-line.
      $line =~ s/\s+$//;                                 # Chomp trailing whitespace (including CR & LF).
      BLAT 'Db Msg in while(), near top:';               # If debugging,
      BLAT "Chomped incoming line = \"$line\".";         # print chomped line.
      my $wc = 0;                                        # Word counter.
      for my $word (split /[\s-]+/, $line) {             # Split line-to-words on whitespace and hyphens.
         $word =~ s/[^\w]//g;                            # Nix non-word characters.
         next if $word eq '';                            # Skip word if empty.
         $word = fc $word;                               # Fold Case.
         push @words, $word;                             # Store word in words list.
         ++$wc;                                          # Increment word counter.
      }                                                  # End of word loop.
      BLAT 'Db Msg in while(), at bottom:';              # If debugging,
      BLAT "This line had $wc words.";                   # print number of words in this line.
   }                                                     # End of line loop.
   my @sorted = sort {length($a) <=> length($b)} @words; # Make a sorted version of our list of words.
   my @unique = uniq @sorted;                            # Nix copies.
   say for @unique;                                      # Say unique words, 1-per-line, smallest-to-largest.
   exit 0;                                               # Exit program, returning success code 0 to caller.
}                                                        # End of main body of program.

# Subroutine definitions:

# Print diagnostics to STDERR if debugging:
sub BLAT ($msg) {if ($Debug) {say STDERR "$msg"}}

# Process @ARGV:
sub argv {
   for ( my $i = 0 ; $i < scalar @ARGV ; ++$i ) {
      local $_ = $ARGV[$i];
      if (/^-/) {
         /^-e$/ || /^--debug$/ and $Debug = 1;
         /^-h$/ || /^--help$/  and $Help  = 1;
         splice @ARGV, $i, 1;
         --$i}}
   return 1}

# Print help message:
sub help {
   print STDERR ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "words-by-lenth.pl". This program prints the words of its input in
   increasing order of length.

   -------------------------------------------------------------------------------
   Command lines:

   words-by-lenth.pl [-h|--help]           (prints this help then exits)
   words-by-lenth.pl < MyFile.txt          (prints words-by-length in a file)
   words-by-lenth.pl file1.txt file2.txt   (prints words-by-length in files)
   some-program | words-by-lenth.pl.pl     (prints words-by-length in STDIN)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print this help and exit.
   -e or --debug      Print diagnostics.

   Single-letter options may NOT be piled-together after a single hyphen.

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   All non-option arguments will be intepreted as paths to files. If one-or-more
   of those files exist and can be read, they will constitute the input to this
   program, and it will print the words-by-length of those files. Any files which
   do NOT exist will cause error messages to be printed, but execution will
   continue for those files which DO exist.

   If there are NO command-line arguments, STDIN will be used as input, instead.
   If there is no content in STDIN, this program will freeze; type some text then
   type Ctrl-D to indicate end-of-input and this program will print the words
   by length of the text you typed.

   Happy words-by-length printing!
   Cheers,
   Robbie Hatley,
   Programmer.
   END_OF_HELP
   return 1;
} # end sub help
