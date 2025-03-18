#!/usr/bin/env perl

# This is a 110-character-wide ASCII Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# random-hexadecimal.pl
# Generates and prints a random hexadecimal number, 1-to-1,000,000 digits long, defaulting to 8 digits.
# Written by Robbie Hatley.
# Edit history:
# Sun Jan 28, 2024: Wrote it.
# Thu Aug 15, 2024: -C63; got rid of unnecessary "use" statements.
# Sun Mar 16, 2025: Changed from UTF-8 to ASCII. Nixed "__END__" marker. Nixed "use v5.36;".
##############################################################################################################

# ======= LEXICAL VARIABLES: =================================================================================

my $Digits = 8; # Number of digits. (1 to 1,000,000, defaulting to 8.)
my @Hex    = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f');
my $Tab    = 0; # Tabulate output to 64 columns?

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub error   ; # Handle errors.
sub help    ; # Print help and exit.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   argv;
   for ( my $i = 1 ; $i <= $Digits ; ++$i ) {
      print $Hex[int rand 16];
      if ($Tab) {
         if (0 == $i%64) {
            print "\n";
         }
      }
   }
   print "\n";
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV :
sub argv {
   for ( @ARGV ) {
      /^-h$/ || /^--help$/    and help and exit 777;
      /^--digits=([1-9]\d*)$/ and $Digits = int($1);
      /^-t$/ || /^--tab$/     and $Tab = 1;
   }
   $Digits < 1 || $Digits > 1000000
   and print "Error: Number of digits must be 1-1,000,000 but you specified $Digits.\n"
   and exit 666;
   return 1;
} # end sub argv

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "random-hexadecimal.pl". This program prints a random positive
   hexadecimal integer, 1-to-1,000,000 digits long, defaulting to 8 digits.

   -------------------------------------------------------------------------------
   Command lines:

   program-name.pl -h|--help                    (to print this help and exit)
   program-name.pl [-t|--tab] [--digits=####]   (to print a hexadecimal integer)

   -------------------------------------------------------------------------------
   Description of options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   --digits=####      Set number of digits to #### (must be 1 to 1000000)
   -t or --tab        Tabulate output to 64 columns.

   All options not listed above, and all non-option arguments, are ignored.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
