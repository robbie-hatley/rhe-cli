#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# character-info.pl
#
# Edit history:
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Tue Oct 03, 2023: Got rid of "common::sense" (who needs it, anyway?). Corrected broken variable inits.
#                   Decreased width from 120 to 110. Upgraged to "v5.36".
# Thu Aug 15, 2024: -C63; Erased unnecessary "use" statements.
# Tue Mar 04, 2025: Added help; reduced minimum version from "5.36" to "5.16"; put blank line before "Line #".
##############################################################################################################

use v5.16;
use utf8;
use Unicode::Normalize 'NFD';
use RH::Dir;

my $line    = '' ; # Line of text.
my $char    = '' ; # Character.
my $lin_num = 0  ; # Line number.
my $chr_num = 0  ; # Character number.
my $rep     = '' ; # Glyphical representation.
my $ord     = 0  ; # Unicode ordinal.
my $type    = '' ; # Character type.
foreach (@ARGV) {
   /^-h$/ || /^--help$/
   and warn "Welcome to Robbie Hatley's nifty character information program.\n".
            "This program prints detailed information for every character of\n".
            "every line of its input. Input is from files given as arguments,\n".
            "or from STDIN if no files are given.\n"
   and exit(777);
}
foreach $line (<>) {
   ++$lin_num;
   print "\nLine #$lin_num: $line\n";
   my @chars = split '',$line;
   foreach $char (@chars) {
      ++$chr_num;

      # Decide representation:
      if    ($char =~ m/\pC/)                          {$rep = "\x{2423}"             ;}
      elsif ($char =~ m/\p{White_Space}/)              {$rep = "\x{2422}"             ;}
      else                                             {$rep = $char                  ;}

      # Get ordinal:
      $ord  = ord $char;

      # Generate type string:
      $type = '';
      if ($char =~ m/\p{White_Space}/)                 {$type .= ' Whitespace'        ;}
      if ($char =~ m/\pC/)                             {$type .= ' Control Character' ;}
      if ($char =~ m/\p{L}/) {
                                                        $type .= ' Letter'            ;
         if ($char =~ m/\p{Ll}/)                       {$type .= ', lower-case'       ;}
         elsif ($char =~ m/\p{Lu}/)                    {$type .= ', upper-case'       ;}
         else                                          {$type .= ', unkwn-case'       ;}
         my $decomposed = NFD $char;
         my $stripped = $decomposed =~ s/\p{M}//rg;
         my $folded = fc $stripped;
         if    ($folded =~ m/[aeiou]/)                 {$type .= ' (vowel    )'       ;}
         elsif ($folded =~ m/[bcdfghjklmnpqrstvwxyz]/) {$type .= ' (consonant)'       ;}
         else                                          {$type .= ' (unknown  )'       ;}
      }
      if ($char =~ m/\pZ/)                             {$type .= ' Separator'         ;}
      if ($char =~ m/\pN/)                             {$type .= ' Numeral'           ;}
      if ($char =~ m/\pM/)                             {$type .= ' Combining Mark'    ;}
      if ($char =~ m/\p{Block: Hangul_Jamo}/)          {$type .= ' Hangul Jamo'       ;}
      if ($char =~ m/\p{Block: Hangul}/)               {$type .= ' Hangul Character'  ;}
      if ($char =~ m/\p{Block: CJK_Strokes}/)          {$type .= ' CJK Stroke'        ;}
      if ($char =~ m/\p{Block: CJK_Symbols}/)          {$type .= ' CJK Symbol'        ;}
      if ($char =~ m/\p{Block: CJK}/)                  {$type .= ' CJK Character'     ;}
      if ($char =~ m/\pS/)                             {$type .= ' Symbol'            ;}
      if ($char =~ m/\pP/)                             {$type .= ' Punctuation'       ;}
      printf("line# %3d char# %2d char = %s\tord = %7d(dec) = %5X(hex)%s\n",
             $lin_num, $chr_num, $rep, $ord, $ord, $type);
   } # end for each character
} # end foreach $line
