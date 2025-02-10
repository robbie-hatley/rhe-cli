#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# testpad256.pl
# Tests validity of a 256-byte-wide one-time pad.
########################################################################################################################

use v5.32;
use utf8;
use experimental 'switch';
use strict;
use warnings;
use warnings FATAL => "utf8";

binmode STDIN;
binmode STDOUT;

use RH::Dir;

sub print_help_msg;

# int main (@ARGV)
{
   if (@ARGV == 1 && ($ARGV[0] eq '-h' || $ARGV[0] eq '--help'))
   {
      print_help_msg();
      exit;
   }

   if ( @ARGV != 1 )
   {
      warn
      (
         "Error: testpad256.pl takes 1 argument which must be\n"
       . "a path to a 256-byte-wide one-time pad.\n"
      );
      print_help_msg();
      exit;
   }

   my  @Pad           = () ; # multi-line 256-byte-wide permutation-based one-time pad
   my  $PadFileName   = '' ; # pad file name
   my  $PadSize       = 0  ; # pad size
   my  $Buffer        = '' ; # buffer to hold data read from pad file
   my  @Line          = () ; # array of 256 bytes
   my  $l             = 0  ; # line number of pad
   my  $i             = 0  ; # right character index for compare
   my  $j             = 0  ; # left  character index for compare
   my  $FoundError    = 0  ; # Have we found any errors?

   $PadFileName = shift @ARGV;

   open(PAD, '< :raw', e $PadFileName) or die "Couldn't open pad.\n$!\n";
   while (1)
   {
      $Buffer = '';
      read(PAD, $Buffer, 256) or last;
      push @Pad, [split //, $Buffer];
      ++$PadSize;
   }
   close PAD;

   say "Pad size = $PadSize";
   LINE: for ( $l = 0 ; $l < $PadSize ; ++$l )
   {
      say "\nNow testing line $l ...";
      @Line = @{$Pad[$l]};
      foreach my $Char (@Line) {print(ord($Char),' ');}
      print "\n";
      if ( 256 != scalar(@Line) )
      {
         $FoundError = 1;
         say "Error: Line $l is not 256 bytes long.";
         next LINE;
      }
      for ( $i = 1 ; $i < 256 ; ++$i )
      {
         for ( $j = 0 ; $j < $i ; ++$j )
         {
            if ( ord($Line[$i]) == ord($Line[$j]) )
            {
               $FoundError = 1;
               say("Error: chars $j and $i of line $l both have ord ", ord($Line[$j]));
            }
         }
      }
   }

   if ($FoundError) {say "\nErrors found; pad is NOT valid.";}
   else             {say "\nNo errors found; pad is valid.";}

   # We're done, so end program:
   exit;
} # end main()


sub print_help_msg
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "testpad256". This program tests 256-byte-wide one-time pads
   for validity. This program takes exactly one argument, which must be a
   path to a 256-byte-wide permutation-based one-time pad. For a pad to be
   valid, each row must consist of a permutation of all 256 possible bytes.

   Cheers,
   Robbie Hatley,
   Programmer
   END_OF_HELP
   return 1;
}
