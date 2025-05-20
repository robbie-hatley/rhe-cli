#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# word-abundances.pl
# Prints the abundances of the words in the strings fed to it.
#
# Edit history:
# Sat Jan 09, 2021: Wrote it.
# Sat Sep 18, 2021: Added help.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Thu Nov 25, 2021: Cleaned up formatting and comments, and added debugging.
# Tue Aug 08, 2023: Upgraded from "v5.32" to "v5.36". Reduced width from 120 to 110.
# Sun Apr 27, 2025: Now using "utf8::all". Simplified shebang to "#!/usr/bin/env perl".
#                   Nixed all "d", "e", and now using "cwd" instead of "d getcwd".
##############################################################################################################

# Pragmas and modules:
use v5.36;
use utf8::all;

# Settings:
my $Debug     = 0;
my $Help      = 0;

# Subroutine predeclarations:
sub BLAT;
sub argv;
sub help;

# Main body of program:
{                                                # Begin main body of program.
   argv;                                         # Process command-line arguments.
   $Help and help and exit 777;                  # If user wants help, just print help and exit.
   my $tw = 0;                                   # Total-words counter.
   my %wh;                                       # Words abundance hash.
   for my $line ( <> ) {                         # Process input line-by-line.
      $line =~ s/\s+$//;                         # Chomp trailing control whitespace (including CR & LF).
      BLAT 'Db Msg in while(), near top:';       # If debugging,
      BLAT "Chomped incoming line = \"$line\"."; # print chomped line.
      my $lw = 0;                                # Line-words counter.
      for my $word (split /\s+/, $line) {        # Split line-to-words on whitespace.
         $word =~ s/\W//g;                       # Nix non-word characters.
         next if $word eq '';                    # Skip word if empty.
         $word = fc $word;                       # Fold Case.
         ++$lw;                                  # Increment line-words counter.
         ++$tw;                                  # Increment total-words counter.
         ++$wh{$word};                           # Record word in abundance hash.
      }
      BLAT 'Db Msg in while(), at bottom:';      # If debugging,
      BLAT "This line had $lw words.";           # print number of words in this line.
   }

   # Print word abundances:
   say "Input contained $tw words, with the following abundances (descending):";
   for my $key (sort {$wh{$b}<=>$wh{$a}} keys %wh) { # Index hash by reverse order of abundance.
      say "$key => $wh{$key}";                       # Display how many strings were received for each key.
   }

   # Exit program, returning success code 0 to caller:
   exit 0;
}

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

   Welcome to "word-abundance.pl". This program prints the abundances of words
   in STDIN or in files mentioned as command-line arguments.

   -------------------------------------------------------------------------------
   Command lines:

   word-abundance.pl [-h|--help]           (prints this help then exits)
   word-abundance.pl < MyFile.txt          (prints word abundance in a file)
   word-abundance.pl file1.txt file2.txt   (prints word abundance in files)
   some-program | word-abundance.pl        (prints word abundance in STDIN)

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
   program, and it will print the relative and absolute abundances of all words
   in those files. Any files which do NOT exist will cause error messages to be
   printed, but execution will continue for those files which DO exist.

   If there are NO command-line arguments, STDIN will be used as input, instead.
   If there is no content in STDIN, this program will freeze; type some text then
   type Ctrl-D to indicate end-of-input and this program will print the word
   abundances of the text you typed.

   Happy word-abundance printing!
   Cheers,
   Robbie Hatley,
   Programmer.
   END_OF_HELP
   return 1;
} # end sub help

