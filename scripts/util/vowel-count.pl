#!/usr/bin/env perl

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# vowel-count.pl
#
# Edit history:
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Thu Nov 25, 2021: Now also printing the "decomposed" version of each string.
# Wed Aug 09, 2023: Upgraded from "v5.32" to "v5.36". Got rid of "common::sense" (antiquated). Reduced width
#                   from 120 to 110. Added strict, warnings, etc, to boilerplate. Now combines all lines into
#                   a single string before counting vowels, and prints only the vowel count, no words.
# Tue Apr 08, 2025: Reduced width from 120 to 110. Simplified shebang to "#!/usr/bin/env perl". Now using CPAN
#                   module "utf8::all" to do all encoding and decoding automatically. Added help. Reduced min
#                   ver from "5.36" to "5.16". Added "-v"/"--verbose" options. Added "sub blat" to print
#                   diagnostics to STDERR only if being verbose.
# Sat May 17, 2025: Split "argv" and "help" to subroutines. Increased min ver from "v5.16" to "v5.36".
#                   "BLAT" function now controlled by "$Debug" rather than "$Verbose".
##############################################################################################################

# Pragmas and modules:
use v5.36;
use utf8::all;
use Unicode::Normalize 'NFD';

# Settings:
my $Debug    = 0 ;
my $Help     = 0 ;

# English, Greek, and Russian vowels, stripped, sorted, and deduped:
my $Vowels   = 'aeiouyαεηιουωаеиоуыэюя';

# Subroutine predeclarations:
sub BLAT;
sub argv;
sub help;

# Main body of program:
{                                                       # Begin main body of program.
   argv;                                                # Process command-line arguments.
   $Help and help and exit 777;                         # If user wants help, just print help and exit.
   my $total = 0;                                       # Make-and-initialize a total-vowels counter.
   while (<>) {                                         # Process each line of input in-turn.
      s/\s+$//;                                         # Chomp trailing whitespace.
      my $letters    = $_ =~ s/[\s\pC\pZ\pN\pP\pS]//gr; # Erase all non-letter characters from string.
      my $decomposed = NFD $letters;                    # Break-up extended grapheme clusters.
      my $stripped   = $decomposed =~ s/\pM//gr;        # Erase diacritics from string.
      next if 0 == length $stripped;                    # Skip line if now blank.
      my $folded     = fc $stripped;                    # Fold Case.
      my $vcount     = 0;                               # Make-and-initialize a local-vowels counter.
      ++$vcount while ($folded =~ m/[$Vowels]/g);       # Count local vowels.
      $total += $vcount;                                # Append local count to total count.
      BLAT '';                                          # Print intermediate results if debugging:
      BLAT "Original   string = $_";                    # Original string.
      BLAT "Letters    string = $letters";              # Just the letters.
      BLAT "Decomposed string = $decomposed";           # Ext. grp. clstrs broken to bases + diacritics.
      BLAT "Stripped   string = $stripped";             # Diacritics removed.
      BLAT "Folded     string = $folded";               # Case folded.
      BLAT "Vowels in line    = $vcount";               # Count of vowels in current line.
   }                                                    # Exit input loop.
   BLAT '';                                             # Print blank line if debugging.
   say $total;                                          # Print total number of vowels in input.
   exit 0;                                              # Exit program, returning 0 to caller.
}                                                       # End main body of program.

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

   Welcome to "vowel-count.pl". This program prints the total number of vowels
   in STDIN or in files mentioned as command-line arguments.

   -------------------------------------------------------------------------------
   Command lines:

   vowel-count.pl [-h|--help]           (prints this help then exits)
   vowel-count.pl < MyFile.txt          (prints number of vowels in a file)
   vowel-count.pl file1.txt file2.txt   (prints number of vowels in files)
   some-program | vowel-count.pl        (prints number of vowels in STDIN)

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
   program, and it will print the number of vowels present in those files. Any
   files which do not exist will cause error messages to be printed, but execution
   will continue for files which DO exist.

   If there are NO command-line arguments, STDIN will be used as input, instead.
   If there is no content in STDIN, this program will freeze; type some text then
   type Ctrl-D to indicate end-of-input and this program will print the number of
   vowels in the text you typed.

   Happy vowel counting!
   Cheers,
   Robbie Hatley,
   Programmer.
   END_OF_HELP
}
