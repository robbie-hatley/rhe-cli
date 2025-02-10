#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# /rhe/scripts/util/backwards.pl
# Prints each line of input text with the graphemes in backwards order. (Doesn't mangle extended grapheme
# clusters!)
# Text is input  from STDIN , or via redirects from files, or via pipes, or via file-name arguments.
# Text is output to   STDOUT, or via redirects from files, or via pipes.
#
# Edit history:
#    Tue Mar 08, 2016: Wrote it.
#    Mon Apr 04, 2016: Simplified and now using -CSDA.
#    Sat Apr 16, 2016: Fixed line-ending bug and added many comments.
#    Sat Dec 16, 2017: Improved comments and help.
#    Thu Mar 18, 2021: Now Doesn't mangle extended grapheme clusters.
########################################################################################################################

use v5.32;
use utf8;
use experimental 'switch';
use strict;
use warnings;
use warnings FATAL => "utf8";

use RH::WinChomp;
use RH::Dir;

sub parg ();
sub help ();

{ # begin main
   parg;
   while(<>)
   {
      remove_bom;
      winchomp;
      say join '', reverse $_ =~ m/\X/g; # "$_ =~ m/\X/g" returns list of all eXtended grapheme clusters in $_
   }
   exit 0;
} # end main

sub parg ()
{
   for ( my $i = 0 ; $i < @ARGV ; ++$i )
   {
      $_ = $ARGV[$i];
      if (/^-[\pL\pN]{1}$/ || /^--[\pL\pM\pN\pP\pS]{2,}$/)
      {
         if ( '-h' eq $_ || '--help' eq $_ ) {help; exit 777;}
         splice @ARGV, $i, 1;
         --$i;
      }
   }
   return 1;
} # end sub parg ()

sub help ()
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Command lines:
   backwards.pl -h|--help              (prints this help)
   backwards.pl                        (reverses text from keyboard)
   backwards.pl file1                  (reverses text from file1)
   backwards.pl < file1                (reverses text from file1)
   backwards.pl < file1 > file2        (reverses text from file1 to file2)
   process1 | backwards.pl | process2  (reverses text from process1 to process2)

   Any options or arguments other than -h or --help are ignored.

   All input  is from STDIN, or from files named in arguments, or from < or | .
   Input data is not altered (unless user purposely over-writes input using >).

   All output is to STDOUT, or to > or | . Output will be a right-to-left
   reversal of the extended grapheme clusters of each line of the input text.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help ()
