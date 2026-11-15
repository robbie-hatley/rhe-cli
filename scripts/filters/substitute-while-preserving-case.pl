#!/usr/bin/env -S perl -CSDA

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# substitute-while-preserving-case.pl
# This program substitutes a given substitution string for case-insensitive
# matches to a given pattern string in a given set of input strings,
# preserving the case of the input strings to the maximum extent possible.
# Eg, "preserve-case.pl 'dog' 'cat'" would change Dog to Cat, dog to cat,
# DoGs to CaTs, dOgerel to cAterel, etc.
# Inputs:
#    cmd-line arg1 = pattern string
#    cmd-line arg2 = substitution string
#    STDIN         = target strings
# Outputs:
#    prints version of input strings with pattern matches replaced by given
#    substitution, to STDOUT.
# Notes:
#    Like most Unix utilities, this program does not alter its inputs.
#    The material coming in on STDIN remains unchanged;
#    all of the changes are on STDOUT only.
# Known bugs:
#    If pattern and/or substitution string contain anything which could be
#    construed as RE metacharacters, the results could get "interesting".
#
# Written by Robbie Hatley on Saturday March 5, 2016.
#
# Edit history:
# Sat Mar 05, 2016: Wrote it.
# Wed Mar 16, 2016: Dramatically improved, got rid of most bugs.
# Sat Apr 16, 2016: Now using -CSDA.
# Tue Nov 09, 2021: Refreshed shebang, colophon, and boilerplate.
# Wed Dec 08, 2021: Reformatted titlecard.
# Sun Aug 04, 2024: Reduced width from 120 to 110. Upgraded from "v5.32" to "v5.36". Added "use utf8".
#                   Got rid of "common::sense", "Sys::Binmode", and "RH::Winchomp".
########################################################################################################################

use v5.36;
use utf8;

use Unicode::UCD qw(charinfo);

sub TransferCase :prototype($$);
sub Help;

$\ = "\n";
$, = ' ';

{ # begin main
   if ($ARGV[0] eq '-h' || $ARGV[0] eq '--help')
   {
      Help();
      exit 0;
   }

   # If number of arguments is out of range, bail:
   if ( @ARGV != 2 )
   {
      warn "Error: \"substitute-while-preserving-case.pl\" requires 2 command-line arguments.";
      Help();
      exit 0;
   }

   my $Pat = $ARGV[0];
   my $Sub = $ARGV[1];

   while (<STDIN>) {
      s/\s+$//;
      s/$Pat/TransferCase($&,$Sub)/ieg;
      say;
   }

   # We be done, so scram:
   exit 0;
} # end main

# Transfer case pattern from one string to another,
# to the extent that the two strings overlap:
sub TransferCase :prototype($$)
{
   my ($A, $B) = @_;
   # Limit case transfer to that part of $Left and $Right which overlap:
   my $Limit = length($A) < length($B) ? length($A) : length($B);
   # Transfer case:
   foreach my $Index (0..$Limit)
   {
      my $AChar = substr($A, $Index, 1);
      my $BChar = substr($B, $Index, 1);

      # Copy case from $AChar to $BChar,
      # if $AChar and $BChar are opposite-case letters:
      substr($B, $Index, 1, lc($BChar))
         if $AChar =~ /\p{Ll}/ && $BChar =~ /\p{Lu}/;
      substr($B, $Index, 1, uc($BChar))
         if $AChar =~ /\p{Lu}/ && $BChar =~ /\p{Ll}/;
   }

   # Return the (possibly altered) $B:
   return $B;
}

sub Help
{
print <<'END_OF_HELP';

"substitute-while-preserving-case.pl" substitutes a given substitution string
for case-insensitive matches to a given pattern string in a given set of target
strings, preserving the case of the target strings to the maximum extent
possible. Eg, "preserve-case.pl 'dog' 'cat'" would change Dog->Cat,
dog->cat, DoGs to CaTs, etc.

Inputs:
   cmd-line arg1 = RE pattern (can contain groups to be referenced)
   cmd-line arg2 = RE substitution (can contain back-references)
   strings to be searched are via STDIN (or redirect or pipe to STDIN)
   NOTE: this program does not alter its inputs.

Outputs:
   prints version of input strings with pattern matches replaced by given
   substitution, preserving case of original as much as possible, to STDOUT.
END_OF_HELP
return 1;
}
