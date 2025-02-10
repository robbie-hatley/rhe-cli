#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

# permute-string.pl

# Given a string of 2-20 characters, this script creates and prints
# all possible permutations of the characters of the string.
# (String-based version. This seems to be much faster than the array version.)

use v5.32;
use utf8;
use Time::HiRes 'time';
use Carp "cluck";

# Variables (WARNING: initializations in the "BEGIN" block below happen BEFORE any initializations here):
my $db          = 0; # Set to 1 to cluck.
my $Perms       = 0; # Count of permutations found.
my $EntryTime      ; # Time of program entry. (Initialized in BEGIN block below. Do NOT re-initialize here!)
my $ExitTime       ; # Time of program exit.  (Initialized in  END  block below.)
my $ElapsedTime    ; # Program run time.      (Initialized in  END  block below.)

sub Extract ($$);
sub Permute ($$);
sub Help    ()  ;

BEGIN
{
   $EntryTime = time;
}

{ # begin main

   # Print help and exist if user requests help:
   if ((@ARGV > 0) && ('-h' eq $ARGV[0] || '--help' eq $ARGV[0]))
   {
      Help();
      exit 777;
   }

   # Otherwise, die if not exactly 1 arg:
   if (1 != scalar(@ARGV))
   {
      say 'Error: Permute takes exactly 1 argument, which must be';
      say 'a string with at least 2 characters and at most 20 characters.';
      say 'Use a "-h" or "--help" option to get help.';
      exit 666;
   }

   # Die if arg is too short or too long:
   if (length($ARGV[0]) < 2 || length($ARGV[0]) > 20)
   {
      say 'Error: Permute takes exactly 1 argument, which must be';
      say 'a string with at least 2 characters and at most 20 characters.';
      say 'Use a "-h" or "--help" option to get help.';
      exit 666;
   }

   Permute('',$ARGV[0]);
   say("Found $Perms permutations.");

} # end main

END
{
   $ExitTime = time;
   $ElapsedTime = $ExitTime - $EntryTime;
   say "Elapsed time = $ElapsedTime seconds.";
   exit(0);
}

# SUBROUTINE DEFINITIONS:

# Extract one character from a given index of a given string,
# close-up the gap, and return extracted character.
# (NOTE: alters thing pointed-to by its first argument.)
sub Extract ($$)
{
   cluck("EXTRACT:") if $db;
   my $Text  = shift; # ref to text (NOT copy of text)
   die 'Error: $Text not a string ref in Extract' if 'SCALAR' ne ref($Text);
   my $Index = shift; # index to erase one char at
   die "Error: \$Index=$Index in Extract" if $Index<0 || $Index>19;
   my $Char  = substr(${$Text}, $Index, 1);
   ${$Text}  = substr(${$Text}, 0, $Index) . substr(${$Text}, $Index+1);
   return $Char;
}

# Given an empty left string and a right string with 2-20 unique characters,
# print all permutations of the right string. (The left string is used an
# accumulator for forming permutations by extracting all characters from
# the right string and appending them to the left in all possible orders.)
sub Permute ($$)
{
   cluck("PERMUTE:") if $db;
   my $left  = shift;
   my $right = shift;
   my $length_left  = length($left);
   my $length_right = length($right);
   my $i;
   if (1 == $length_right)
   {
      say $left . $right;
      ++$Perms;
   }
   else
   {
      for ( $i = 0 ; $i < $length_right ; ++$i )
      {
         my $temp_left  = $left;
         my $temp_right = $right;
         $temp_left .= Extract(\$temp_right, $i);
         Permute($temp_left, $temp_right);
      }
   }
   return 1;
}

sub Help ()
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);
   Welcome to "permute-string.pl", Robbie Hatley's nifty string permuter.
   Given a string of 2-to-20 characters in length, as a command-line argument,
   this program prints all possible permutations of that string, one-per-line.

   Command lines:
   permute-string.pl [-h | --help]  (to get this help)
   permute-string.pl MyString       (to permute a string)
   END_OF_HELP
   return 1;
}
