#!/opt/perl/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

#
# See https://theweeklychallenge.org/blog/perl-weekly-challenge-150
#

#
# Run as: perl ch-1.pl < input-file
#

#
# Not sure what the restriction that both numbers are of the same
# length is going to buy us anything. We don't buy anything from
# the fact the input consists of digits only either.
#

my $LENGTH = 51;

while (<>) {
    my ($fib_prev, $fib_last) = /[0-9]+/g;
    while (length ($fib_last) < $LENGTH) {
        ($fib_prev, $fib_last) = ($fib_last, $fib_prev . $fib_last);
    }
    say substr $fib_last, $LENGTH - 1, 1;
}
use strict;
use warnings;
##
# You are given two strings having same number of digits, $a and $b.
# Write a script to generate Fibonacci Words by concatenation of  
# the previous two strings. Print the 51st digit of the first term
# having at least 51 digits.
## 

sub _fibonacci_words_51{
    my($accumulated) = @_;
    my $i = @{$accumulated} - 1;
    my $next = $accumulated->[$i - 1] . $accumulated->[$i];
    return substr($next, 51 - 1, 1) if length($next) >= 51;
    push @{$accumulated}, $next;
    _fibonacci_words_51($accumulated);
}

sub fibonacci_words{
    my($u, $v) = @_;
    return _fibonacci_words_51([$u, $v]);
}

MAIN:{
    print fibonacci_words(q[1234], q[5678]) . "\n";    
}#!/usr/bin/env perl
use strict;
use warnings;
use feature qw'say state signatures';
no warnings qw'experimental::signatures';

# TASK #1 › Fibonacci Words
# Submitted by: Mohammad S Anwar
#
# You are given two strings having same number of digits, $a and $b.
#
# Write a script to generate Fibonacci Words by concatenation of the previous
# two strings. Finally print 51st digit of the first term having at least 51
# digits.
# Example:
#
#     Input: $a = '1234' $b = '5678'
#     Output: 7
#
#     Fibonacci Words:
#
#     '1234'
#     '5678'
#     '12345678'
#     '567812345678'
#     '12345678567812345678'
#     '56781234567812345678567812345678'
#     '1234567856781234567856781234567812345678567812345678'
#
#     The 51st digit in the first term having at least 51 digits
#     '1234567856781234567856781234567812345678567812345678' is 7.

run() unless caller();

sub run() {

    # For the current challenge we start by getting the two input words from the
    # argument list.
    my ( $a, $b ) = @ARGV;

    # Afterwards we ensure both strings have equal lengths. We will not check
    # that both words only contain digits as it doesn't matter for the algorithm
    # wether we restrict the input to be only digits or allow arbitrary
    # characters. (Actually it doesn't even matter that they are of the same
    # length, but I will work with that restriction)
    die "Expect two input words of equal length!\n"
      unless length($a) && length($a) == ( length($b) // 0 );

    # Now we pass both words to the meat of this solution, the `fibonacci_word`
    # routine. We additionaly pass the minimum length of 51 charachters up to
    # which we will build the fibonnaci word
    my $fibonacci_word = fibonacci_word( $a, $b, 51 );

    # Finally we extract the 51st charachter (at index 50) from the build word
    # and print it out as our result.
    my $target = substr( $fibonacci_word, 50, 1 );
    say $target;

}

sub fibonacci_word ( $a, $b, $length ) {

    # The actual fibonacci_word routine cries for a recursive solution. As
    # always with a recursive solution we start with defining the exit
    # condition, which is fullfilled as soon as the $a string reaches at least
    # the requested length $length. In that case $a is the final fibonacci word
    # and we return it to the caller
    return $a if length($a) >= $length;

    # Otherwise we continue the process, by passing $b as the new $a to the
    # fibonacci_word routine and accumulating the next fibonacci word (the
    # concatenation of $a and $b) into $b
    return fibonacci_word( $b, $a . $b, $length );
}
#! /usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use Getopt::Long;

my $verbose =  0;

GetOptions("verbose" => \$verbose);

my $a = $ARGV[0] || 1234;
my $b = $ARGV[1] || 5678;
my $i = 4;

die 'Please specify digits only for $a' unless $a =~ /^\d+$/;
die 'Please specify digits only for $b' unless $b =~ /^\d+$/;

say ": 1: $a" if $verbose;
say ": 2: $b" if $verbose;

($a, $b) = ($b, $a . $b);

say ": 3: $b" if $verbose;

while (length($b) < 51)
{
  ($a, $b) = ($b, $a . $b);  
  say ": " . $i++ . ": $b" if $verbose;
}

say substr($b, 50, 1);
#!perl

###############################################################################
=comment

Perl Weekly Challenge 150
=========================

TASK #1
-------
*Fibonacci Words*

Submitted by: Mohammad S Anwar

You are given two strings having same number of digits, $a and $b.

Write a script to generate Fibonacci Words by concatenation of the previous two
strings. Finally print 51st digit of the first term having at least 51 digits.

Example:

    Input: $a = '1234' $b = '5678'
    Output: 7

    Fibonacci Words:

    '1234'
    '5678'
    '12345678'
    '567812345678'
    '12345678567812345678'
    '56781234567812345678567812345678'
    '1234567856781234567856781234567812345678567812345678'

    The 51st digit in the first term having at least 51 digits
    '1234567856781234567856781234567812345678567812345678' is 7.

=cut
###############################################################################

#--------------------------------------#
# Copyright © 2022 PerlMonk Athanasius #
#--------------------------------------#

#==============================================================================
=comment

Algorithm
---------
As with the standard Fibonacci sequence, each term is generated by combining
the two immediately-preceding terms. In this case, "combining" is done by con-
catenation rather than addition.

Extensions
----------
I have extended the Task in two ways:

(1) An explanation of the answer is provided in the form given in the Example.
    The required digit is highlighted in-place in the final Fibonacci word by a
    caret symbol directly below. (The explanation may be suppressed by setting
    the constant $VERBOSE to a false value.)

(2) The constant $TARGET may be set to any integer value greater than 1, and
    the output will still be correct.

=cut
#==============================================================================

use strict;
use warnings;
use Const::Fast;

use constant VERBOSE => 1;

const my $TARGET => 51;
const my $USAGE  =>
"Usage:
  perl $0 <a> <b>

    <a>    A string of digits
    <b>    Another string of digits of the same length\n";

#------------------------------------------------------------------------------
BEGIN
#------------------------------------------------------------------------------
{
    $| = 1;
    print "\nChallenge 150, Task #1: Fibonacci Words (Perl)\n\n";
}

#==============================================================================
MAIN:
#==============================================================================
{
    my ($A, $B) = parse_command_line();

    print "Input:  \$a = '$A' \$b = '$B'\n";

    my  $length = length $A;
    my ($x, $y) = ($A, $B);
    my  @words  = ($A, $B)           if VERBOSE;

    while ($length < $TARGET)
    {
        my $z = $x . $y;
           $x = $y;
           $y = $z;

        $length = length $y;

        push @words, $y              if VERBOSE;
    }

    my $fib   = $TARGET > length $A ? $y : $A;
    my $digit = substr $fib, $TARGET - 1, 1;

    print "Output: $digit\n";

    explain( $fib, $digit, \@words ) if VERBOSE;
}

if (VERBOSE)
{
    #--------------------------------------------------------------------------
    sub explain
    #--------------------------------------------------------------------------
    {
        my ($fib, $digit, $words) = @_;

        print  "\nFibonacci Words:\n\n";

        print  "'$_'\n" for @$words;

        printf "\nThe %s digit in the first term having at least %d digits\n",
                ordinal( $TARGET ), $TARGET;

        printf "'%s' is %d\n%s^\n", $fib, $digit, ' ' x $TARGET;
    }

    #--------------------------------------------------------------------------
    sub ordinal
    #--------------------------------------------------------------------------
    {
        my ($num) = @_;
        my  $suff = 'th';
        my  $dig1 = int( ($num % 100) / 10 );          # Tens digit

        if ($dig1 != 1)
        {
            my $dig0 = $num % 10;                      # Ones digit

            $suff = $dig0 == 1 ? 'st' :
                    $dig0 == 2 ? 'nd' :
                    $dig0 == 3 ? 'rd' : 'th';
        }

        return $num . $suff;
    }
}

#------------------------------------------------------------------------------
sub parse_command_line
#------------------------------------------------------------------------------
{
    my $args = scalar @ARGV;
       $args == 2 or error( "Expected 2 command line arguments, found $args" );

    / ^ \d+ $ /x  or error( qq["$_" contains a non-digit] ) for @ARGV;

    length $ARGV[ 0 ] == length $ARGV[ 1 ]
                  or error( 'The strings are different lengths' );

    return @ARGV;
}

#------------------------------------------------------------------------------
sub error
#------------------------------------------------------------------------------
{
    my ($message) = @_;

    die "ERROR: $message\n$USAGE";
}

###############################################################################
use Modern::Perl;
use experimental qw<signatures>;

sub task1 ( $x, $y, $pos ) {
    return substr $x, $pos-1, 1 if length($x) < $pos;
    ($x, $y) = ($y, "$x$y")  while length($y) < $pos;
    return substr $y, $pos-1, 1;
}

@ARGV = qw<1234 5678> if not @ARGV;
die if @ARGV != 2;
say task1( @ARGV, 51 );
#!/Users/colincrain/perl5/perlbrew/perls/perl-5.32.0/bin/perl
#
#       150-1-the-51st-little-piece-of-string.pl
#
#       Fibonacci Words
#         Submitted by: Mohammad S Anwar
#         You are given two strings having same number of digits, $a and $b.
# 
#         Write a script to generate Fibonacci Words by concatenation of
#         the previous two strings. Finally print 51st digit of the first
#         term having at least 51 digits.
# 
#         Example:
#             Input: $a = '1234' $b = '5678'
#             Output: 7
# 
#             Fibonacci Words:
# 
#             '1234'
#             '5678'
#             '12345678'
#             '567812345678'
#             '12345678567812345678'
#             '56781234567812345678567812345678'
#             '1234567856781234567856781234567812345678567812345678'
# 
#             The 51st digit in the first term having at least 51 digits:
#                 '1234567856781234567856781234567812345678567812345678' is 7.

#         method:
# 
#             The Fibonacci sequence is defined by what is known asa
#             "recurrence relation". Elements previously defined in the
#             sequence re-occur as components of later definitions
#             according to certain rules of construction. Thus it follows
#             that values at a certain points in the sequence cannot
#             generally be constructed until the required previous values
#             that they are contingent on existing have themselves been
#             constructed. An ordering is necessitated, and to evaluate the
#             n-th member of the sequence we need to work backwards
#             recursively, defining the components, and their components,
#             as required until we arrive at known values and can return
#             forward in the construction.
# 
#             The recurrence relation of the Fibonacci numbers is
# 
#                 F(n) = F(n-1) + F(n-2)
# 
#             but this is not the only recurrence relation that can exist,
#             and many variations have been explored. In the simplest form,
#             a new element is a function of the value for the single
#             preceding element. The specific Fibonacci sequence works
#             forward from the starting values (0,1) but other inital
#             conditions with the same recurrence can be constructed.
#             Altering the coeffiecients of the components is another
#             option, as is involving more than the two previous terms in
#             the computation, or altering the operations acting on the
#             previous elements selected to something other than simple
#             addition.
# 
#             This interesting qualities about these sequences is often the
#             way the mathematics of the recursive definition relates to
#             such other mathematical ideas such as series expansions and
#             generating functions. The fact that its recursive definition
#             notwithstanding the n-th element of the Fibonacci sequence
#             can be directly calculated using a function of n, known as
#             Binet's formula, a closed-form expression, reveals deep
#             connections between linear recurrence relations and linear
#             differential equations.
# 
#             This generalized branching out from the specific defintion of
#             the Fibonacci numbers brings us to the idea that we needn't
#             even require numbers to apply a recurrence relation. The
#             method of constuction is the key pattern; that this is made
#             from that and that, and those made themselves from smaller
#             components, all according to a defined set of rules that
#             remain the same independent of scale. The one-millionth term
#             is computed from the previous two, in the same way the third
#             term is. If we use strings instead of numbers, and in a
#             manner analogous to addition concatinate the strings, we have
#             what is known as a sequence of Fibonacci words. If the
#             initial conditions specify that the strings have equal
#             length, as is the case here, than the lengths of the strings
#             composed will follow the Fibonacci sequence, with the values
#             multiplied by the word length.
# 
#             The term "Fibonacci word" is often used for the
#             closely-defined sequence using the two binary digits
#             (0,1) as initializers and applying concatenation. This task
#             takes a broader approach, allowing any equal-length strings
#             of digits for the starting values. 
# 
#             Unary notation can be thought of as moving around piles of
#             sticks. Starting with the two "words" ("", 1) the resulting
#             sequence, viewed as numbers in unary notation, is not just
#             similar to but is the Fibonacci numbers.
# 
#             Starting with a null, empty string (using '' for this lack of
#             a character) we initialize with 
# 
#                 ('', 1)
# 
#             Once we start generating new values we get
# 
#                 '', 1, 1, 11, 111, 11111, 11111111, ...
# 
#             As we can see the count of the 1s shows the Fibonacci
#             sequence in unary:
# 
#                 0, 1, 1, 2, 3, 5, 8, ...
# 
#             We will still use decimal notation of the sequence index, and
#             construct the terms the same way, only applying the string
#             concatenation operator. 
# 
#             Because this operation is not commutative, we need to specify
#             that F(n) = F(n-2) • F(n-1).
# 
#             Because our indexing is 0-based we are looking for the
#             character at index 50.
# 
# 
# 
# 
#       © 2022 colin crain
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##t



use warnings;
use strict;
use utf8;
use feature ":5.26";
use feature qw(signatures);
no warnings 'experimental::signatures';

my $zero = shift // qw( 1234 );
my $one  = shift // qw( 5678 );

my @F = ($zero, $one);

while (length $F[-1] < 51) {
    push @F, $F[-2] . $F[-1]
}

say "the words generated, with a helpful guide:\n";
say $_ for @F;
say '';

say "0123456789" x 6;
say (map {"$_         "} (' ', 1..5));
say '';

say "start string 0: ", $zero;
say "start string 1: ", $one;


say qq(\nthe 51st character in the first term long enough to have one is "), 
        (substr $F[-1], 50, 1), q(")



#!/usr/bin/env perl

use strict;
use warnings;
use feature qw{ say postderef signatures state };
no warnings qw{ experimental };

use Getopt::Long;
use List::Util qw{ sum0 max };

say fibonacci_words( '1234', '5678' );

sub fibonacci_words ( $word1, $word2 ) {
    my @words;
    push @words, $word1, $word2;
    while ( length $words[-1] < 51 ) {
        my $w = $words[-2] . $words[-1];
        push @words, $w;
    }
    my $last = pop @words;
    # zero indexing leads to possible fencepost error
    return substr $last, 50, 1;
}
use strict;
use warnings;

print "No args provided!\n" unless @ARGV == 2;
my ($s1, $s2) = @ARGV;

sub fibonacci_words{
  my (@arr) = @_;
  do{
    push @arr, $arr[-2] . $arr[-1];
  }while(length $arr[$#arr] < 52);

  return (split //, $arr[$#arr])[50];
}

print fibonacci_words($s1, $s2);
#!/usr/bin/perl
# 
# TASK #1 - Fibonacci Words
# 
# You are given two strings having same number of digits, $a and $b.
# 
# Write a script to generate Fibonacci Words by concatenation of the
# previous two strings. Finally print 51st digit of the first term having
# at least 51 digits.
# 
# Example:
# 
#     Input: $a = '1234' $b = '5678'
#     Output: 7
# 
#     Fibonacci Words:
# 
#     '1234'
#     '5678'
#     '12345678'
#     '567812345678'
#     '12345678567812345678'
#     '56781234567812345678567812345678'
#     '1234567856781234567856781234567812345678567812345678'
# 
#     The 51st digit in the first term having at least 51 digits
#     '1234567856781234567856781234567812345678567812345678' is 7.
# 
# MY NOTES: Pretty easy.  Fibonacci words == append two previous strings.
#	Use -d (debug mode) to see all the above explanatory info.
# 

use strict;
use warnings;
use feature 'say';
use Getopt::Long;
use Data::Dumper;
use List::Util qw(sum);

my $debug=0;
die "Usage: fib-words [--debug] A B\n"
	unless GetOptions( "debug"=>\$debug ) && @ARGV==2;
my( $a, $b ) = @ARGV;

my @out = "Fibonacci words\n\'$a'\n'$b'";

for(;;)
{
	# form next Fibonacci word
	my $next = $a.$b;
last if length($b) > 50;
	push @out, "'$next'";
	$a = $b;
	$b = $next;
}

my $digit51 = substr($b,50,1);
push @out, "\nThe 51st digit in the first term having at least 51 digits";
push @out, "'$b', is $digit51";

say "Output: $digit51";

if( $debug )
{
	say "";
	say for @out;
}
#!/usr/bin/perl
use warnings;
use strict;

use constant GOAL => 51;

sub fibonacci_words_slow {
    my (@w) = @_;
    while (GOAL > length $w[0]) {
        push @w, shift(@w) . $w[0];
    }
    return substr $w[0], GOAL - 1, 1
}

=head1 The following hash was generated by the following code:

  use feature qw{ say };
  sub generate {
      for my $l (1 .. 52) {
          my @ws;
          for my $w (0, 1) {
              $ws[$w] = [ map [$w, $_], 0 .. $l - 1 ];
          }
          while (GOAL > @{ $ws[0] }) {
              push @ws, [ @{ shift @ws }, @{ $ws[0] } ];
          }
          say "$l => [$ws[0][GOAL - 1][0], $ws[0][GOAL - 1][1]],";
      }
  }

=cut

my %length2pos = (
     1 => [0, 0],
     2 => [1, 0],
     3 => [0, 2],
     4 => [1, 2],
     5 => [1, 0],
     6 => [0, 2],
     7 => [1, 1],
     8 => [0, 2],
     9 => [1, 5],
    10 => [1, 0],
    11 => [1, 6],
    12 => [1, 2],
    13 => [0, 11],
    14 => [0, 8],
    15 => [0, 5],
    16 => [0, 2],
    17 => [1, 16],
    18 => [1, 14],
    19 => [1, 12],
    20 => [1, 10],
    21 => [1, 8],
    22 => [1, 6],
    23 => [1, 4],
    24 => [1, 2],
    25 => [1, 0],
);
sub fibonacci_words {
    my (@w) = @_;
    my $l = length $w[0];

    my ($word_index, $pos)
        = $l >= GOAL             ? (0, GOAL - 1)
        : exists $length2pos{$l} ? @{ $length2pos{$l} }
                                 : (1, GOAL - $l - 1);

    return substr $w[$word_index], $pos, 1
}

use Test::More tests => 53;
is fibonacci_words_slow('1234', '5678'), '7', 'Example';

my $W = join "", map chr, 1 .. 200;
for my $l (1 .. GOAL + 1) {
    my $w1 = substr $W, 0, $l;
    my $w2 = substr $W, -$l;
    is fibonacci_words_slow($w1, $w2),
        fibonacci_words($w1, $w2),
        "Length $l";
}

use Benchmark qw{ cmpthese };
cmpthese(-3, {
    slow => sub {
        for my $l (1 .. 100) {
            my $w1 = substr $W, 0, $l;
            my $w2 = substr $W, -$l;
            fibonacci_words_slow($w1, $w2)
        }
    },
    fast => sub {
        for my $l (1 .. 100) {
            my $w1 = substr $W, 0, $l;
            my $w2 = substr $W, -$l;
            fibonacci_words($w1, $w2)
        }
    }
});
#!/usr/local/bin/perl

use strict;

use warnings;
use feature qw(say);
use Test::More;
use Benchmark qw(cmpthese timethis);
use Data::Dumper qw(Dumper);

my @TESTS = (
  [ [1234,5678], 7 ],
  [ [5678,1234], 3 ],
);
is( fibnum(       @{$_->[0]} ), $_->[1] ) foreach @TESTS;
is( fibnum_nasty( @{$_->[0]} ), $_->[1] ) foreach @TESTS;
is( fibnum_messy( @{$_->[0]} ), $_->[1] ) foreach @TESTS;

done_testing();

sub fibnum_messy {
  ($a,$b)=@_;$b=$a.($a=$b)while 51>length$b;substr$b,50,1;
}

sub fibnum_nasty {
  my ($r,$s) = @_;
  $s=$r.($r=$s) while 51>length $s;
  substr $s,50,1;
}
sub fibnum {
  my ( $r, $s ) = @_;
  ( $r, $s ) = ( $s, $r.$s ) while 51 > length $s;
  substr $s, 50, 1;
}
#!/usr/bin/perl -s

use v5.16;
use Test2::V0;
use Coro::Generator;
use experimental 'signatures';

our ($tests, $examples, $verbose);

run_tests() if $tests || $examples;	# does not return

die <<EOS unless @ARGV == 3;
usage: $0 [-examples] [-tests] [-verbose] [W1 W2 I]

-examples
    run the examples from the challenge
 
-tests
    run some tests

-verbose
    print intermediate Fibonacci words

W1 W2 I
    generate Fibonacci words from W1 and W2 until the length I is reached
    and pick the Ith character

EOS


### Input and Output

say pick_from_fib_word(@ARGV);


### Implementation

# Generate Fibonacci words from W1 and W2 until the length I is reached
# and pick the Ith character.
sub pick_from_fib_word ($w1, $w2, $i) {
    my $gen = gen_fibonacci_words($w1, $w2);
    my $f = '';
    # Generate the needed word and print it in verbose mode.
    ($f = $gen->(), $verbose) && say $f while $i > length $f;

    substr($f, $i - 1, 1);
}

# Build a generator for the Fibonacci word sequence starting with W1 and
# W2.
sub gen_fibonacci_words ($w1, $w2) {
    generator {
        yield $w1;
        yield $w2;
        while () {
            ($w1, $w2) = ($w2, $w1 . $w2);
            yield $w2;
        }
    }
}


### Examples and tests

sub run_tests {
    SKIP: {
        skip "examples" unless $examples;

        is pick_from_fib_word(1234, 5678, 51), 7, 'example';
    }

    SKIP: {
        skip "tests" unless $tests;

        my $fib_words = gen_fibonacci_words(1234, 5678);
        is [map $fib_words->(), 1 .. 7],
        [qw(1234 5678 12345678 567812345678 12345678567812345678
        56781234567812345678567812345678
        1234567856781234567856781234567812345678567812345678)],
        'list of fibonacci words';
	}

    done_testing;
    exit;
}
use strict;
use warnings;
use feature "say";

sub fibonacci {
    my ($a, $b) = @_;
    my @fib = $a < $b ? ($a, $b) : ($b, $a);
    for my $i (1..20) {
        push @fib, $fib[-2] . $fib[-1];
        next if length $fib[-1] < 51;
        say $fib[-1];
        return $fib[-1];
    }
}
say substr fibonacci(1234, 5678), 50, 1;
use strict;
use warnings;

sub get_fib_word {
    my ($word1, $word2) = @_;

    while (length($word2) < 51) {
        my $new_word = $word1.$word2;
        $word1 = $word2;
        $word2 = $new_word;
    }

    return substr($word2,50,1);
}

use Test::More;

is(get_fib_word('1234', '5678'), 7);
done_testing;
#!/usr/bin/perl

use strict;
use warnings;
use English;

################################################################################
# Begin main execution
################################################################################

my $a = "1234";
my $b = "5678";
my $n = 51;

printf(
    "\n    Input: \$a = '%s' \$b = '%s' \$n = %d\n    Output: %s\n\n",
    $a, $b, $n,
    fibonacci_words($a, $b, $n)
);

exit(0);
################################################################################
# End main execution; subroutines follow
################################################################################



################################################################################
# Concatenate strings in a manner analagous to the calculation of Fibonacci
# numbers, and get the Nth character from the string once the string has at
# least that many characters
# Takes three arguments:
# * The first string to concatenate
# * The second string to concatenate
# * An integer N that indicates which character in the constructed string is
#   desired
# Returns on success:
# * The Nth character in the constructed string
# Returns on error:
# * undef if N is not greater than zero (0)
################################################################################
sub fibonacci_words{
    my $a = shift();
    my $b = shift();
    my $n = int(shift());

    return(undef)
        unless($n > 0);

    my $c = "";

    # Loop until the string is long enough
    while(length($b) < $n){
        $c = $a . $b;
        $a = $b;
        $b = $c;
    }

    # String is zero-indexed so subtract
    # from $n
    return(substr($b, $n - 1, 1));

}



#!/usr/bin/perl

=head1

Week 150:

    https://theweeklychallenge.org/blog/perl-weekly-challenge-150

Task #1: Fibonacci Words

    You are given two strings having same number of digits, $a and $b.

    Write a script to generate Fibonacci Words by concatenation of the previous two strings. Finally print 51st digit of the first term having at least 51 digits.

=cut

use strict;
use warnings;
use Test::More;

is(fibonacci_words('1234', '5678', 51), 7, 'Example');

done_testing;

#
#
# METHOD

sub fibonacci_words {
    my ($term_1, $term_2, $index) = @_;

    while (length($term_1 . $term_2) <= $index) {
        ($term_1, $term_2) = ($term_2, $term_1 . $term_2);
    }

    return substr($term_1 . $term_2, --$index, 1);
}
#!/usr/bin/env perl

# Challenge 150
#
# Input: $a = '1234' $b = '5678'
# Output: 7
#
# Fibonacci Words:
#
# '1234'
# '5678'
# '12345678'
# '567812345678'
# '12345678567812345678'
# '56781234567812345678567812345678'
# '1234567856781234567856781234567812345678567812345678'
#
# The 51st digit in the first term having at least 51 digits
# '1234567856781234567856781234567812345678567812345678' is 7.

use Modern::Perl;

my $pos = 51;

@ARGV==2 or die "Usage: ch-1.pl word word\n";
my @words = @ARGV;
my $fib_word = fib_word(@words[0..1], $pos);
say substr($fib_word, $pos-1, 1);

sub fib_word {
    my($a, $b, $len) = @_;
    my @seq = ($a, $b);
    while (length($seq[-1]) <= $len) {
        push @seq, $seq[-2].$seq[-1];
        shift @seq;
    }
    return $seq[-1];
}
#!/bin/perl

=pod

The Weekly Challenge - 150
 - https://perlweeklychallenge.org/blog/perl-weekly-challenge-150/#TASK1

Author: Niels 'PerlBoy' van Dijke

TASK #1 › Fibonacci Words
Submitted by: Mohammad S Anwar

You are given two strings having same number of digits, $a and $b.

Write a script to generate Fibonacci Words by concatenation of the
previous two strings. Finally print 51st digit of the first term having 
at least 51 digits.

=cut

use v5.16;
use strict;
use constant LEN => 51;

use Data::Printer;

# Prototype
sub fibStr ($$$);


@ARGV = (1234, 5678) unless @ARGV == 2;

my ($i, $f) = (1);
$f = fibStr($ARGV[0], $ARGV[1], $i++) while (length($f) < LEN);

printf "The %dth digit in the first having at least 51 digits '%s' is '%s'\n",
       LEN, $f, substr($f, LEN-1, 1);


sub fibStr ($$$) {
  my ($s1, $s2, $n) = @_;

  my $k = "$s1:$s2";

  state $s = {};
  $s->{$k} //= [$s1, $s2];

  my $r = $s->{$k};

  $r->[@$r] = $r->[@$r-2] . $r->[@$r-1]
    while (@$r < $n);

  return $r->[$n-1]
}

#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: 15001.pl
#
#        USAGE: ./15001.pl A B 
#
#  DESCRIPTION: Output "Fibonacci strings" starting with A and B
#               and the 51st char of the first string to have that many
#
#       AUTHOR: Pete Houston (pete), cpan@openstrike.co.uk
# ORGANIZATION: Openstrike
#      VERSION: 1.0
#      CREATED: 31/01/22
#===============================================================================

use strict;
use warnings;

my $offset = 51;

my @fib = @ARGV[0,1];
die "Unequal lengths.\n" unless length ($fib[0]) eq length ($fib[1]);

while ($offset > length $fib[1]) {
	push @fib, $fib[0] . $fib[1];
	shift @fib;
	print "$fib[1]\n";
}

printf "Char at position %i is %s\n",
	$offset,
	substr ($fib[1], $offset - 1, 1);
#!/usr/bin/perl

# Peter Campbell Smith - 2022-01-31
# PWC 150 task 1

use v5.28;
use strict;
use warnings;
use utf8;

# You are given two strings having same number of digits, $a and $b.
# Write a script to generate Fibonacci Words by concatenation of the previous two 
# strings. Finally print 51st digit of the first term having at least 51 digits.

my ($a, $b, $index, $j, $test, @fib, @tests);

# sets of inputs to test ($a, $b, character index of interest)
@tests = (['1234', '5678', 51], ['12345678', '98765432', 159], ['1', '2', 1000]);

# loop over tests
for $test (@tests) {
	
	# get parameters
	($fib[0], $fib[1], $index) = @$test;
	
	# create successive ternms of series until one is long enough
	$j = 1;
	while (1) {
		$j ++;
		$fib[$j] = $fib[$j - 2] . $fib[$j - 1];
		last if length($fib[$j]) >= $index;
	}
	
	# format the answer
	say qq[\nInput:  $fib[0], $fib[1]];
	say qq[Term $j is $fib[$j] (] . length($fib[$j]) . ' characters long)';
	say qq[Character $index is ] . substr($fib[$j], $index - 1, 1);
}
#!/usr/bin/env perl
use 5.024;
use warnings;
use English qw< -no_match_vars >;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

say "Fibonacci Words:\n";
my $it = fibonacci_words_iterator(@ARGV);
while ('necessary') {
   my $item = $it->();
   say "'$item'";
   if (length $item >= 51) {
      my $digit = substr $item, 50, 1;
      say "\nThe 51st digit in the first term having at least 51 digits '$item' is $digit.";
      last;
   }
}

sub fibonacci_words_iterator ($f0, $f1) {
   my @cache = ('', '', $f0, $f1);
   my $backlog = 2;
   return sub {
      if (! $backlog) {
         ($f0, $f1) = ($f1, $f0 . $f1);
         return $f1;
      }
      --$backlog;
      return $backlog ? $f0 : $f1;
   };
}
#!perl.exe

use strict;
use warnings;
use 5.30.0;

# Author: Robert DiCicco
# Date: 31-JAN-2022
# Challenge 150 Fibonacci Words (Perl)

my $a = '1234';
my $b = '5678';

say "Fibonacci Words";
say $a;
say $b;

my $retval=Fib($a, $b);

# get the 51st character
my $fibchr = substr($retval, 50, 1);
say "51st digit is $fibchr";

# recursive routine to create fibonacci series, but using strings

sub Fib {
  my $val = $_[0] . $_[1];
  say $val;

  # if new string length is less than 51, go another round using new combined string

  if (length($val) < 51) {
    Fib($_[1], $val);
  } else {
    # return the string if length 51 or greater
    return $val;
  }
}
#! /usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

is(fibstr("1234","5678",51),'7','example 1');

sub fibstr {
  my ($aa,$bb,$limit) = @_;
  my $a=$aa;
  my $b=$bb;
  while (1) {
    my $c=$a.$b;
    print "$c\n";
    if (length($c) >= $limit) {
      return substr($c,$limit-1,1);
    }
    ($a,$b)=($b,$c);
  }
}
#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

sub main {
    my @fibs = @_;

    # Sanity check
    if ( scalar(@fibs) != 2 ) {
        die "You must specify two inputs\n";
    }
    if ( length( $fibs[0] ) != length( $fibs[1] ) ) {
        die "Strings must be of the same length\n";
    }

    # Keep compounding the strings until we have at least 51 digits
    while ( scalar(@fibs) == 2 or length( $fibs[-1] ) < 51 ) {
        push @fibs, $fibs[-2] . $fibs[-1];
    }

    # Print the 51st character from the last string
    say substr( $fibs[-1], 50, 1 );
}

main(@ARGV);#!/usr/bin/perl ;
use strict ;
use warnings ;
use feature 'say' ;

say "Enter a number string!" ;
my $A = <STDIN> ;
chomp $A ;
while ( $A !~ /\A\d+\z/ ) {
  say "the string should consist of digits only!" ;
  $A = <STDIN> ;
  chomp $A ;
}
say "Enter a second number string!" ;
my $B = <STDIN> ;
chomp $B ;
while ( $B !~ /\A\d+\z/ ) {
  say "the string should consist of digits only!" ;
  $B = <STDIN> ;
  chomp $B ;
}
while ( length $B != length $A || $B !~ /\A\d+\z/ ) {
  say ("second number string should be " . length( $A ) .
    " characters long!") ;
  say "digits only!" ;
  $B = <STDIN> ;
  chomp $B ;
}
my @fibonacciWords = ($A , $B) ;
while ( length($fibonacciWords[-1]) < 51 ) {
  push @fibonacciWords , $fibonacciWords[-2] . $fibonacciWords[-1] ;
}
say substr( $fibonacciWords[-1] , 50 , 1 ) ;
#!/usr/bin/env perl
# Perl weekly challenge 150
# Task 1: fibonacci words
#
# See https://wlmb.github.io/2022/01/31/PWC150/#task-1-fibonacci-words
use v5.12;
use warnings;
die "Usage: ./ch-1.pl word word [N]" .
    "to get the N-th (default=51) character of a fibonacci word"
    unless @ARGV>=2;
my ($x, $y, $N)=@ARGV;
$N//=51;
die "N should be >=1" unless $N>=1;
die "Words should not be empty"
    unless length $x > 0 && length $y > 0;
say "Fibonacci sequence:";
say($x), ($x, $y)=($y, $x . $y) until length($x)>=$N;
say $x;
say "\n$N-th letter: ", substr $x,$N-1,1;
