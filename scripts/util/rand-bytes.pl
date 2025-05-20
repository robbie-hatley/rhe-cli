#!/usr/bin/env perl
# rand-bytes.pl
# Generates 1-to-1,000,000 random bytes and prints them to STDOUT,
# after setting STDOUT's binmode to ":raw". Written at an unknown
# date by Robbie Hatley.

use v5.36;

sub help {
   print STDERR ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "rand-bytes.pl". This program outputs random bytes. By default, it
   outputs 100 random bytes, but if you use a positive-integer argument in the
   1-1000000 range, it will output the number of random bytes you specify.

   -------------------------------------------------------------------------------
   Command lines:

   rand-bytes.pl -h | --help   (to print this help and exit)
   rand-bytes.pl x             (to output x random bytes)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print this help and exit.
   All other options are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   This program can take 1 optional argument which, if present, must be a positive
   integer in the 1-1000000 range indicating how many random bytes to output.

   Happy random byte generation!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
}

# Check @ARGV to see if user wants help:
for (@ARGV) {
   /^-h$|^--help$/ and help and exit 777;
}

# Set number of bytes:
my $size = 100;
if ( @ARGV && 0+$ARGV[0] >= 1 && 0+$ARGV[0] <=1000000 ) {
   $size = $ARGV[0];
}

# Generate $size random bytes:
my $buffer;
srand;
for ( my $i = 0 ; $i < $size ; ++$i ) {
   my $rand = int(rand()*256);
   my $byte = chr($rand);
   $buffer .= $byte;
}

# Print result:
binmode STDOUT, ':raw';
print STDOUT $buffer;
