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
# Sun Apr 13, 2025: Got rid of shebang (not used by modules, because not executable).
#                   Added "sub safe" to safely display control characters.
##############################################################################################################

# Package:
package RH::RegTest;

# Pragmas:
use v5.36;
use strict;
use warnings;
use utf8;

# NOTE: Don't use "use parent 'Exporter';" here, because this module doesn't export anything,
# because it is a class.

# Encodings:
use open ':std', IN  => ':encoding(UTF-8)';
use open ':std', OUT => ':encoding(UTF-8)';
use open         IN  => ':encoding(UTF-8)';
use open         OUT => ':encoding(UTF-8)';
# NOTE: These may be over-ridden later. Eg, "open($fh, '< :raw', e $path)".
# NOTE: Can't use "utf8::all" here, because it's only for package "main".

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

# Render control codes with ordinals 0x00 through 0x1f visible and safe,
# by adding 0x2400 to their ordinals:
sub safe {
   my $text = shift;
   $text =~ s/([\x00-\x1f\x7f])/chr(ord($1)+0x2400)/eg;
   return $text;
}

# Match input against regexp:
sub match {
   my $self    = shift;
   my $regexp  = $self->{RegExp};
   my $text    = shift;
   my $safe    = safe($text);
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
      say ( "Content of \$` = \"",     safe($`) , "\""   );
      say ( "Length  of \$& = "  ,   length($&) ,        );
      say ( "Content of \$& = \"",     safe($&) , "\""   );
      say ( "Length  of \$' = "  ,   length($') ,        );
      say ( "Content of \$' = \"",     safe($') , "\""   );
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
