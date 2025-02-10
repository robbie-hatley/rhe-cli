#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file.
# ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# /rhe/scripts/util/backwards.pl
# Prints the extended grapheme clusters of its input in reverse order, starting at the very end of input and
# working backwards. Thus the first character printed will be the last character of the entire input file or
# stream.
#
# Text is input  from STDIN , or via redirects from files, or via pipes, or via file-name arguments.
# Text is output to   STDOUT, or via redirects from files, or via pipes.
#
# Edit history:
#    Thu Mar 18, 2021: Wrote it.
########################################################################################################################

use v5.32;
use strict;
use warnings;
use utf8;
#use warnings FATAL => "utf8";


use RH::WinChomp;
use RH::Dir;

sub parg ();
sub help ();

{ # begin main
   parg;
   my @Lines;
   while(<>)
   {
      remove_bom;
      winchomp;
      # Reverse extended grapheme clusters of each line,
      # then put each new line ABOVE the previous line:
      unshift @Lines, join '', reverse $_ =~ m/\X/g;
   }
   # Finally, print the double-reversed (horizontally & vertially) text:
   say for @Lines;
   exit 0;
} # end main

sub parg ()
{
   for ( my $i = 0 ; $i < @ARGV ; ++$i )
   {
      $_ = $ARGV[$i];
      if (/^-[\pL\pN]{1}$/ || /^--[\pL\pM\pN\pP\pS]{2,}$/)
      {
         /^-h$/ || /^--help$/ and help;
         splice @ARGV, $i, 1;
         --$i;
      }
   }
   return 1;
} # end sub parg ()

sub help ()
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "reverse.pl", Robbie Hatley's nifty text reverser.
   This program reverses all text fed to it, both horizontally
   AND vertically. Extended grapheme clusters (such as in
   fully-decomposed Vietnamese) are not mangled.

   Command lines:
   reverse.pl -h|--help              (prints this help)
   reverse.pl                        (reverses text from keyboard)
   reverse.pl file1                  (reverses text from file1)
   reverse.pl < file1                (reverses text from file1)
   reverse.pl < file1 > file2        (reverses text from file1 to file2)
   process1 | reverse.pl | process2  (reverses text from process1 to process2)

   Any options or arguments other than -h or --help are ignored.

   All input  is from STDIN, or from files named in arguments, or from < or | .
   Input data is not altered (unless user purposely over-writes input using >).

   All output is to STDOUT, or to > or | . Output will be a bottom-to-top AND
   right-to-left reversal of the extended grapheme clusters of the input text.

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help ()
