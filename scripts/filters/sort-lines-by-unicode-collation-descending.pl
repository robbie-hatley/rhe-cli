#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# sort-lines-by-unicode-collation-descending.pl
#
# Written by Robbie Hatley on Wednesday December 8, 2021.
#
# Edit history:
# Wed Dec 08, 2021: Wrote it.
# Sun Aug 04, 2024: Reduced width from 120 to 110. Upgraded from "v5.32" to "v5.36". Added "use utf8".
#                   Got rid of "common::sense" and "Sys::Binmode".
##############################################################################################################





use v5.36;
use utf8;

use Unicode::Collate;

# ======= SUBROUTINE PRE-DECLARATIONS ========================================================================

sub argv                       ;
sub pre_process                ;
sub process_line :prototype(_) ;
sub help_msg                   ;

# ======= MAIN BODY OF PROGRAM ===============================================================================

MAIN:
{
   argv;
   my $collator = Unicode::Collate->new(preprocess=>\&pre_process);
   say for reverse $collator->sort( map {process_line} <> );
   exit 0;
} # end MAIN

# ======= SUBROUTINE DEFINITIONS =============================================================================

sub argv {
   # If user wants help, just print help and bail:
   if ( @ARGV > 0 && ( $ARGV[0] eq '-h' || $ARGV[0] eq '--help' ) ) {
      help_msg;
      exit 0;
   }

}

sub pre_process {
   my $str = shift;
   #$str =~ s/\b(?:an?|the)\s+//gi;
   return $str;
}

# Chop-off BOM (if any) from start of line, and chop off
# newlines (if any from ends of lines:
sub process_line :prototype(_) {
   s/^\N{BOM}//; # Get rid of BOM (if any).
   s/\s+$//;     # Chomp-off newlines.
   return $_;    # Return result.
}

sub help_msg {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to Robbie Hatley's Nifty unicode collation utility.
   This program unicode-sorts the lines of a file and prints the results to
   STDOUT. The original file is never altered.

   Input  is via STDIN,  pipe, first argument, or redirect from file.

   Output is via STDOUT, pipe, or redirect to file.

   Command lines to sort a file:
   usort infile.txt
   usort < infile.txt > outfile.txt
   usort < infile.txt | uniq > outfile.txt

   Command lines to get help:
   usort -h
   usort --help

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
}
