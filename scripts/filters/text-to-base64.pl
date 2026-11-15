#!/usr/bin/env -S perl -CSDA

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# text-to-base64.pl
# Converts plain text (from stdin) to base64 encoding (to stdout).
# Written by Robbie Hatley.
# Edit history:
# Sat Jul 16, 2022: Wrote it.
# Sun Aug 04, 2024: Reduced width from 120 to 110. Upgraded from "v5.32" to "v5.36". Added "use utf8".
#                   Got rid of "common::sense" and "Sys::Binmode".
##############################################################################################################

use v5.36;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    :prototype()  ; # Process @ARGV.
sub base64  :prototype($) ; # Convert text to base64.
sub help    :prototype()  ; # Print help and exit.

# ======= VARIABLES: =========================================================================================

my $db = 0; # Debug (print diagnostics)?
my @charset = split //,'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'; # base64 charset

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   argv;
   if ($db)
   {
      for ( my $i = 0 ; $i < 64 ; ++$i )
      {
         printf("charset[%2d] = %s\n", $i, $charset[$i]);
      }
      exit 0;
   }
   while (<>)
   {
      say base64($_);
   }
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV :
sub argv :prototype()
{
   for ( @ARGV )
   {
      if ( $_ eq '-h' || $_ eq '--help' ) {help; exit 0;}
   }
   return 1;
} # end sub argv ()

# Convert text to base64:
sub base64 :prototype($)
{
   my $text = shift;            # Incoming line of text.
   my @chars = split //, $text; # List of the chars of $text.
   my $binary_one;              # Text representation of binary representation  of ordinal  of  a  character from @char.
   my $binary_all;              # Text representation of binary representations of ordinals of ALL characters in  @char.
   my @hex;                     # 6-digit clusters from $binary_all;
   my $base64;                  # base64-encoded version of input text.

   # Concatenate the text representations of the binary representations of the ordinals of the characters of $text
   # to $binary_all:
   for ( @chars )
   {
      $binary_one  = sprintf("%08b", ord $_);
      $binary_all .= $binary_one;
   }

   # Right-0-pad $binary_all to have length be a multiple of 6:
   while ( 0 != length($binary_all)%6 ) {$binary_all .= '0';}

   # Snip 6-digit clusters from front of $binary_all and store in @hex:
   while ( length($binary_all) > 0 )
   {
      push @hex, substr $binary_all, 0, 6, '';
   }

   # Set $base64 equal to a concatenation of characters of @charset at indexes given by the decimal values of
   # the elements of @hex:
   for ( @hex )
   {
      $base64 .= $charset[oct '0b'.$_];
   }

   # Right-pad $base64 with "=" as necessary to give it a length which is a multiple of 4:
   while ( 0 != length($base64)%4 )
   {
      $base64 .= '=';
   }

   # We're done, so return result:
   return $base64;
} # end sub base64 ($)

# Print help:
sub help :prototype()
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "text-to-base64.pl". This program converts plain text (from stdin)
   to base64 encoding (to stdout).

   Command lines:
   text-to-base64.pl -h | --help            (to print this help and exit)
   text-to-base64.pl < infile > outfile     (to encode text in base64)

   Description of options:
   Option:             Meaning:
   "-h" or "--help"    Print help and exit.
   All other options are ignored.

   Description of arguments:
   This program ignores all arguments.

   Happy base64 encoding!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help ()

