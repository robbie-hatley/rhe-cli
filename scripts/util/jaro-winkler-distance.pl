#!/usr/bin/env -S perl -CSDA

# jaro-winkler-distance.pl

=pod

The Weekly Challenge 010-2, "Jaro-Winkler distance".
Solution in Perl by Robbie Hatley, written Thu Aug 29, 2024.

simj = 0==m ? 0
            : (1/3)*(m/l1 + m/l2 + (m-t)/m)

simw = simj+lp(1-simj)
     = simj*(1-lp)+lp

dw   = 1 - simw

Where:

"dw" = Jaro-Winkler Distance

"simw" = Jaro-Winkler Similarity

"lp" = one tenth of the number of the first 5 characters which match from the beginning.
For example, "wordiness" and "wordsworth" have an lp of "0.4", whereas "sword" and "sward"
only have an lp of "0.2". (The "rd" doesn't count, because the match starts at the beginning
and ends before the first non-matching character.)

"simj" = Jaro Similarity, which is 0 if m=0 else (1/3)*(m/l1 + m/l2 + (m-t)/m)

"m" = Number of matching characters within a distance of floor(max(l1,l2)/2)-1;
any one character of string1 or string2 may be counted as a "match" only once,
and a match at zero distance should be preferred over a match at non-zero distance.

"t" is one half of the number of characters which match in the wrong order (index
order in string2 opposite of index order in string1).

"l1" is the length of string1.

"l2" is the length of string2.

=cut

# Pragmas and modules:
use v5.15;                       # To get say and fc.
use POSIX      qw( floor ceil ); # To get floor and ceiling functions.
use List::Util qw( min   max  ); # To get min and max of list of numbers.

# If user wants help, just give help and exit:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to Robbie Hatley's "Jaro-Winkler Distance" program.
   This program takes exactly two arguments, which are strings
   to be compared, and will print the following similarity metrics
   for the given pair of strings:
   1. Prefix similarity.
   2. Number of matching characters.
   3. Number of transpositions.
   4. Jaro similarity.
   5. Jaro distance.
   6. Jaro-Winkler Similarity.
   7. Jaro-Winkler Distance.

   Happy string-pair comparing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
}

for (@ARGV) {'-h' eq $_ || '--help' eq $_ and help and exit}

# If we don't have 2 arguments, print error message, give help, and exit:
2 != @ARGV and warn "Error: Invalid input. Help follows.\n" and help and exit;

# Get strings and their lengths:
my $string1 = fc $ARGV[0];
my $string2 = fc $ARGV[1];
my $l1 = length $string1;
my $l2 = length $string2;

# Calculate prefix similarity, which is one tenth of the characters within the first 5 characters of each
# string which match contiguously from the starts of the two strings:
my $lp = 0;
for ( my $idx = 0 ; $idx < min(5,$l1,$l2) ; ++$idx ) {
   substr($string1, $idx, 1) ne substr($string2, $idx, 1) and last;
   ++$lp;
}
$lp /= 10;

# Determine numbers of matches and transpositions:
my $m = 0;          # Count of matches.
my $t = 0;          # Count of transpositions.
my $prevmatch = -1; # What is the index in $string2 of the previous match?
my $currmatch = -1; # What is the index in $string2 of the current  match?
my %used;           # Don't re-use matches!
for my $i (0..$l1-1) {
   # Generate search indices for $string2, starting at zero distance and increasing to max distance:
   my @indices = ();
   # Add zero-distance if it's in-range and unused:
      if ($i >= 0 && $i < $l2 && !$used{$i}) {push @indices, $i;}
   # Add non-zero distances if they're in-range and unused:
   for my $range (1..floor(max($l1,$l2)/2)-1) {
      if ($i-$range >= 0 && $i-$range < $l2 && !$used{$i-$range}) {push @indices, $i-$range}
      if ($i+$range >= 0 && $i+$range < $l2 && !$used{$i+$range}) {push @indices, $i+$range}
   }
   # Now search in $string2 for a character matching index $i of $string1,
   # starting at zero distance and increasing to max allowable distance:
   for my $j (@indices) {
      if (substr($string1, $i, 1) eq substr($string2, $j, 1)) {
         # If we get to here, $j a match, so increment $m, mark $j as "used", and set $currmatch to $j:
         ++$m;
         ++$used{$j};
         $currmatch = $j;
         # If this is also a transposition, also increment $t:
         ++$t if $currmatch < $prevmatch;
         # Update $prevmatch and move on to next index in $string1:
         $prevmatch = $currmatch;
         last;
      }
   }
}
# Each pair of transposed characters is 1 "transposition", so cut $t in half:
$t*=0.5;

# Jaro Similarity:
my $simj; $m > 0 and $simj = (1/3)*($m/$l1 + $m/$l2 + ($m-$t)/$m) or  $simj = 0;

# Jaro Distance:
my $dstj = 1 - $simj;

# Jaro-Winkler Similarity:
my $simw = $simj*(1-$lp)+$lp;

# Jaro-Winkler Distance:
my $dstw = 1 - $simw;

# print results:
say "Prefix similarity       = $lp";
say "Number of matches       = $m";
say "Transpositions          = $t";
say "Jaro         Similarity = $simj";
say "Jaro         Distance   = $dstj";
say "Jaro-Winkler Similarity = $simw";
say "Jaro-Winkler Distance   = $dstw";
