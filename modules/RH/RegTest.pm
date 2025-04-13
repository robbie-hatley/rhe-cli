#! /usr/bin/perl

# This is a 120-character-wide UTF-8 Unicode Perl source-code text file with hard Unix line breaks ("\x{0A}").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# RH/RegTest.pm
# Regular Expression Test Module
# Class for testing regular expressions.
# Usage:
#    my $tester = RH::RegTest->new(@ARGV);
#    $tester->match($MyDamnString);
# Written by Robbie Hatley.
# Edit history:
# Tue Mar 24, 2015:
#    Wrote it.
# Sun Dec 31, 2017:
#    use v5.26.
# Sat Nov 20, 2021: use v5.32. Renewed colophon. Revamped pragmas & encodings.
# Wed Aug 23, 2023: Upgraded from "v5.32" to "v5.36". Reduced width from 120 to 110. Got rid of CPAN module
#                   "common::sense" (antiquated). Got rid of all prototypes. Now using signatures.
# Thu Aug 24, 2023: Changed to C-style {bracing}. Got rid of "o" option on the qr// (unnecessary).
#                   Added some comments to clarify various tricky bits.
# Mon Aug 28, 2023: Fixed bug in which, if capture $1 is "0", it will be reported as "no captures".
# Thu Oct 03, 2024: Got rid of Sys::Binmode.
##############################################################################################################

# Package:
package RH::RegTest;

# Pragmas:
use v5.36;
use strict;
use warnings;
use utf8;
use warnings FATAL => 'utf8';

# CPAN modules:
# (none)
# Note: Don't use "use parent 'Exporter';" here, because this module doesn't export anything,
# because it is a class. Also, don't put -CSDA on the shebang, because it's too late for that.

# Encodings:
use open ':std', IN  => ':encoding(UTF-8)';
use open ':std', OUT => ':encoding(UTF-8)';
use open         IN  => ':encoding(UTF-8)';
use open         OUT => ':encoding(UTF-8)';
# NOTE: these may be over-ridden later. Eg, "open($fh, '< :raw', e $path)".

# Make a new regexp tester:
sub new {
   my $class  = shift;
   my $re = @_ ? shift : '^.+$';
   my $RegExp = qr/$re/;
   if ( ! defined $RegExp ) {die "Bad RegExp \"$re\".\n$!\n";}
   say '';
   say '-------------------------------------------------------------------------------';
   say "New RegTest object: \$RegExp = \"$RegExp\"";
   my $self = {RegExp => $RegExp};
   return bless $self, $class;
}

   # Render certain control codes visible and safe:
   sub safe1 {
      local $_ = shift;
      my $forbid;
      $forbid .= "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f";
      $forbid .= "\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f";
      my $replac;
      $replac .= "\x{2400}\x{2401}\x{2402}\x{2403}\x{2404}\x{2405}\x{2406}\x{2407}";
      $replac .= "\x{2408}\x{2409}\x{240a}\x{240b}\x{240c}\x{240d}\x{240e}\x{240f}";
      $replac .= "\x{2410}\x{2411}\x{2412}\x{2413}\x{2414}\x{2415}\x{2416}\x{2417}";
      $replac .= "\x{2418}\x{2419}\x{241a}\x{241b}\x{241c}\x{241d}\x{241e}\x{241f}";
      return eval("tr/$forbid/$replac/r");
   }

   # Render certain control codes visible and safe:
   sub safe2 {
      my $text = shift;
      foreach my $idx (0..length($text)-1) {
         my $o = ord(substr($text,$idx,1));
         if ( $o < 32 ) {
            substr($text, $idx, 1, chr($o+0x2400));
         }
      }
      return $text;
   }

sub match {
   my $self    = shift;
   my $regexp  = $self->{RegExp};
   my $text    = shift;
   my $safe    = safe2($text);
   say '';
   say "New regexp test with \$text = \"$safe\".";
   say 'Length of $text = ', length($text), '.';
   my @matches = $text =~ m/$regexp/;
   # If match, the above will return the list (1) if no captures, or the list ($1, $2, $3...) if captures.
   # If no match, the above will return the list (). So either way, we can easily determine match/no-match
   # by if (@matches), because "if" forces scalar context, same as "if (scalar(@matches))".
   if (@matches) {
      say "Text matches regexp.";
      say ( "Length  of \$` = "  ,   length($`) ,        );
      say ( "Content of \$` = \"",          $`  , "\""   );
      say ( "Length  of \$& = "  ,   length($&) ,        );
      say ( "Content of \$& = \"",          $&  , "\""   );
      say ( "Length  of \$' = "  ,   length($') ,        );
      say ( "Content of \$' = \"",          $'  , "\""   );
      # If there were 1-or-more captures, $1 will be set; otherwise, $1 will be undefined.
      # So the easiest way to determine "Were there captures?" is "if (defined $1) {...} else {...}".
      if ( defined $1 ) {
         say scalar(@matches), " captures: ", join(', ', map {"\"$_\""} @matches);
      }
      else {
         say('No captures.');
      }
   }
   else {
      say "Text does NOT match regexp.";
   }
}

1;
