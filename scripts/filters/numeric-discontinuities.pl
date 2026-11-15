#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# numeric-discontinuities.pl
# Prints numeric discontinuities in input text.
# Written by Robbie Hatley.
# Edit history:
# Mon Nov 09, 2026: Wrote it.
##############################################################################################################

use v5.40;
use utf8::all;
use Cwd::utf8;

# ======= SUBROUTINE PREDECLARATIONS: ========================================================================

sub argv;
sub help;

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main

   # Process @ARGV:
   argv;

   # Filter input to output:
   my $prev_num = 0;
   my $curr_num = 0;
   while (<>) {
      next unless m/\d+/;
      $curr_num = 0 + $&;
      print if $curr_num != $prev_num + 1;
      $prev_num = $curr_num;
   }

} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV:
sub argv {
   # Declare and define certain variables we'll need:
   my $e = 0;                # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   my @opts = ();            # options

   # Pull all options OUT of @ARGV and put them in @opts instead:
   for ( my $i = 0 ; $i <= $#ARGV ; ++$i ) {
      # If current item is end-of-options marker, remove it from @ARGV, set "$e", and consider all remaining
      # contents of @ARGV to be "arguments" rather than "options":
      if ( '--' eq $ARGV[$i] ) {
         $e = 1;
         splice @ARGV, $i, 1;
         --$i;
      }
      # Else if current item is an "option", remove it from @ARGV and push it to @opts:
      elsif ( !$e && ( $ARGV[$i] =~ /^-(?!-)$s+$/ || $ARGV[$i] =~ /^--(?!-)$d+$/ ) ) {
         push @opts, splice @ARGV, $i, 1;
         --$i;
      }
      # Otherwise, this item is an argument, so leave it in @ARGV:
      else {
         ; # Do nothing.
      }
   }
   # @ARGV now contains NO options; if any items remain, they will be construed by <> as being input files.

   # Process options:
   for ( @opts ) {
      /^-$s*h$s*$/ || /^--help$/ and help and exit(0);
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Print help:
sub help {
   print STDERR ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "numeric-discontinuities.pl". Fed lines of text containing positive
   integers embedded in the text, this program will print only those lines who's
   numbers are not 1 greater than the previous line's number.

   -------------------------------------------------------------------------------
   Command lines:

   numeric-discontinuities.pl -h | --help    (to print this help and exit)
   numeric-discontinuities.pl   source       (to print discontinuities)
   numeric-discontinuities.pl < source       (to print discontinuities)
   source | numeric-discontinuities.pl       (to print discontinuities)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print this help and exit.
         --           End of options (all further CL items are arguments).

   If you want to use an argument that looks like an option (say, you want to
   search for files which contain "--help" as part of their name), use a "--"
   option; that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above will be ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   Any arguments will be construed as being paths to files containing text to be
   processed.


   Happy discontinuity printing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
