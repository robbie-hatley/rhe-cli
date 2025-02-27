#!/usr/bin/perl

# This is an 120-character-wide Unicode UTF-8 Perl-source-code text file.
# ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

########################################################################################################################
# /rhe/scripts/util/preserve-case-xor-test.pl
# This program substitutes a given substitution string for
# case-insensitive matches to a given pattern string in a given set of target
# strings, preserving the case of the target strings to the maximum extent
# possible. Eg, "preserve-case.pl 'dog' 'cat'" would change Dog to Cat,
# dog to cat, DoGs to CaTs, dOgerel to cAterel, etc.
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
# Edit history:
#    Sat Mar 05, 2016 - Wrote it.
#    Wed Mar 16, 2016 - Dramatically improved, got rid of most bugs.
########################################################################################################################

use v5.32;
use strict;
use warnings;

use utf8;
use warnings FATAL => "utf8";
use open qw( :encoding(utf8) :std );
use Encode;
BEGIN {$_ = decode_utf8 $_ for @ARGV;}

use Unicode::UCD qw(charinfo);

use RH::WinChomp;

sub TransferCase ($$);
sub Help ();

$\ = "\n";
$, = ' ';

# main
{
   if ('-h' eq $ARGV[0] || '--help' eq $ARGV[0])
   {
      Help();
      exit 777;
   }

   # If number of arguments is out of range, bail:
   if ( 2 != scalar @ARGV )
   {
      warn "Error: \"preserve-case.pl\" requires 2 command-line arguments.";
      Help();
      exit 666;
   }

   my $Pat = $ARGV[0];
   my $Sub = $ARGV[1];

   while (my $Line = <STDIN>)
   {
      winchomp $Line;
      $Line =~ s/$Pat/TransferCase($&,$Sub)/ieg;
      print $Line;
   }

   # We be done, so scram:
   exit 0;
} # end MAIN

sub TransferCase ($$)
{
   my ($A, $B) = @_;
   my $Limit = length($A) < length($B) ? length($A) : length($B);
   foreach my $Index (0..$Limit)
   {
      my $AChar = substr($A, $Index, 1);
      my $BChar = substr($B, $Index, 1);
      my $Lower = lc $AChar;
      my $Mask  = $AChar ^ $Lower;
      substr($B, $Index, 1, $BChar ^ $Mask);
   }
   return $B;
}

sub Help ()
{
print <<'END_OF_HELP';
"preserve-case.pl" substitutes a given substitution string for
case-insensitive matches to a given pattern string in a given set of target
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
