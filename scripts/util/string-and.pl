#!/usr/bin/env -S perl -C63

# string-and.pl

# Written by Robbie Hatley on Mon Mar 24, 2025.

# Pragmas:
use v5.36;
use strict;
use warnings;
use utf8;

# CPAN modules:
use List::MoreUtils qw( pairwise );

# ======= VARIABLES: =========================================================================================

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 0         ; # Be verbose?               0,1,2     Be quiet.
my $X         = 'U8DeI{_@'; # String 1                  string
my $Y         = 'mÄ&w5*f/'; # String 2                  string
my $Z         = ''        ; # $X & $Y                   string

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub error   ; # Handle errors.
sub help    ; # Print help and exit.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   argv;
   $Help and help and exit 777;
   $Z = str_and($X,$Y);
   if ($Verbose) {
      print ' x  = '; str_print($X);
      print ' y  = '; str_print($Y);
      print 'x&y = '; str_print($Z);
      say '';
      print ' x  = '; bin_print($X);
      print ' y  = '; bin_print($Y);
      print 'x&y = '; bin_print($Z);
   }
   else {
      str_print($Z);
   }
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV:
sub argv {
   # Get options and arguments:
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {           # For each element of @ARGV,
      /^--$/                 # "--" = end-of-options marker = construe all further CL items as arguments,
      and $end = 1           # so if we see that, then set the "end-of-options" flag
      and push @Opts, $_     # and push the "--" to @Opts
      and next;              # and skip to next element of @ARGV.
      !$end                  # If we haven't yet reached end-of-options,
      && ( /^-(?!-)$s+$/     # and if we get a valid short option
      ||  /^--(?!-)$d+$/ )   # or a valid long option,
      and push @Opts, $_     # then push item to @Opts
      or  push @Args, $_;    # else push item to @Args.
   }

   # Process options:
   for ( @Opts ) {
      /^-$s*h/ || /^--help$/    and $Help    =  1  ;
      /^-$s*v/ || /^--verbose$/ and $Verbose =  1  ;
   }

   # Process arguments:

   # Get number of arguments:
   my $NA = scalar(@Args);

   # If we're not getting help, and user typed other-than-2 arguments, or arguments which
   # aren't a pair of equal-length strings, then print error and help messages and exit:
   if ( !$Help && ( 2 != $NA || length($Args[0]) != length($Args[1]) ) ) {error($NA);help;exit 666}

   # First argument, if present, is first string:
   if ( $NA > 0 ) {$X = $Args[0]}

   # Second argument, if present, is second string:
   if ( $NA > 1 ) {$Y = $Args[1]}

   # Return success code 1 to caller:
   return 1;
}

# Return the bit-wise AND of two strings:
sub str_and ($x, $y) {
   if (length($x) != length($y)) {
      die "Error: strings are of unequal length.\n";
   }
   my @xbin = map {ord} split //, $x;
   my @ybin = map {ord} split //, $y;
   my @zbin = pairwise { $a & $b } @xbin, @ybin;
   return join '', map {chr} @zbin;
}

# Print a sequence of ordinals as left-zero-padded binary integers of length 8, 16, 24, or 32 bits:
sub bin_print ($x) {
   for my $ord (map {ord} split //, $x) {
      # 1 byte:
      if ($ord < 2**8) {
         printf("%08b ", $ord);
      }
      # 2 bytes:
      elsif ($ord < 2**16) {
         printf("%016b ", $ord);
      }
      # 3 bytes:
      elsif ($ord < 2**24) {
         printf("%024b ", $ord);
      }

      # 4 bytes:
      elsif ($ord < 2**32) {
         printf("%032b ", $ord);
      }
   }
   print "\n";
}

# Print a string of bytes as a Unicode string, after substituting any unprintable or illegal ordinals:
sub str_print ($x) {
   my @charset;
   for (0..255) {
      $charset[$_]=$_;
   }
   @charset[0..31] = map {ord} qw( ␀ ␁ ␂ ␃ ␄ ␅ ␆ ␇ ␈ ␉ ␊ ␋ ␌ ␍ ␎ ␏ ␐ ␑ ␒ ␓ ␔ ␕ ␖ ␗ ␘ ␙ ␚ ␛ ␜ ␝ ␞ ␟ ␠);
   $charset[127] = ord('␡');
   @charset[128..159] = (ord('�')) x 32;
   my $string = join '', map {chr} map { ( $_ < 256 ) ? $charset[$_] : $_} map {ord} split //, $x;
   say $string;
}

# Handle errors:
sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $NA arguments, but this program needs exactly
   2 command-line arguments, which must be equal-length strings.
   Help follows.
   END_OF_ERROR
   return 1;
} # end sub error

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "string-and.pl". Given two equal-length strings as command-line
   arguments, this program ANDs them together, character-by-character, by
   computing the bitwise AND of ordinals of each character pair. In the case that
   the resulting ordinal is under 256, if the ordinal is non-printing (0-31) or
   invalid in iso-8859-1 (128-159), the ordinal is replaced by a suitable
   replacement ordinal. (For ordinals over 255, no replacement is done by this
   program, and it is up to the user's viewing agent to supply a replacement
   ordinal, such as "�", for ordinals which are not valid Unicode codepoints.)

   -------------------------------------------------------------------------------
   Command lines:

   string-and.pl  -h|--help                 (to print this help and exit)
   string-and.pl  [options] [Arg1] [Arg2]   (to and-together two stings)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -v or --verbose    Be verbose. (Default is to be terse.)
         --           End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen.

   If you want to use an argument that looks like an option, use a "--" option;
   that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   In addition to options, this program needs exactly 2 mandatory arguments,
   which must be equal-length strings. This program will then print their
   bit-wise AND.


   Happy string ANDing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help

