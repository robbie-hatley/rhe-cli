#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# extract-dream-by-number.pl
# Extracts a dream from my dream log by number.
# Written by Robbie Hatley.
# Edit history:
# Sun Nov 02, 2025: Wrote it.
##############################################################################################################

use strict;
use warnings;
binmode STDIN  , ":encoding(utf8)" or die "Couldn't binmode STDIN  to \":encoding(utf8)\".\n$!\n";
binmode STDOUT , ":encoding(utf8)" or die "Couldn't binmode STDOUT to \":encoding(utf8)\".\n$!\n";
use warnings FATAL => "utf8";

# Selected CPAN Modules which may be helpful (erase whatever's not needed):
use Scalar::Util qw( looks_like_number reftype );
use Regexp::Common;
use Unicode::Normalize;
use Unicode::Collate;
use MIME::QuotedPrint;

# ======= VARIABLES: =========================================================================================

my @Opts;
my @Args;
my $Help  = 0 ; # Print help and exit?
my $Debug = 0 ; # Print diagnostic messages using BLAT?

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV:
sub argv {
   # Get options and arguments:
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {           # For each element of @ARGV:
      !$end                  # If we have not yet reached end-of-options,
      && /^--$/              # and we see an "--" option,
      and $end = 1           # set the "end-of-options" flag
      and push @Opts, '--'   # and push "--" to @Opts
      and next;              # and skip to next element of @ARGV.
      !$end                  # If we have not yet reached end-of-options,
      && ( /^-(?!-)$s+$/     # and if we see a valid short option
      ||  /^--(?!-)$d+$/ )   # or a valid long option,
      and push @Opts, $_     # then push item to @Opts
      and next;              # and skip to next element of @ARGV.
      push @Args, $_;        # Otherwise, push item to @Args.
   }

   # Process options:
   for ( @Opts ) {
      /^-$s*h/ || /^--help$/    and $Help    =  1  ;
      /^-$s*e/ || /^--debug$/   and $Debug   =  1  ;
   }

   # Process arguments:

   # Get number of arguments:
   my $NA = scalar(@Args);

   # Add code here to process arguments, if this program will use arguments.

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Print messages only if debugging:
sub BLAT {my $string = shift; if ($Debug) {print STDERR "$string\n"}}

# Print help:
sub help {
   print STDERR ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   [Tailor this intro to describe what your program does.]
   Welcome to "asdf.pl". This program does blah blah blah to input text
   and outputs the result, without altering the input text. All input is via
   STDIN and all output is via STDOUT. Use of pipes and/or redirects to channel
   text flow is highly recommended.

   -------------------------------------------------------------------------------
   Command lines:

   asdf.pl -h | --help                       (to print this help and exit)
   asdf.pl [options] [Arg1] [Arg2] [Arg3]    (to [perform function] )

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print this help and exit.
   -e or --debug      Print diagnostic messages.
         --           End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen.
   If multiple conflicting separate options are given, latter overrides former.
   If multiple conflicting single-letter options are piled after a single hyphen,
   the precedence is the inverse of the options in the above table.

   If you want to use an argument that looks like an option (say, you want to
   search for files which contain "--recurse" as part of their name), use a "--"
   option; that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above will be ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   [If your program will use arguments, describe here what they do.]

   Happy text filtering!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help

# ======= MAIN BODY OF PROGRAM: ==============================================================================

# Process @ARGV:
argv;

# If user requested help, print help and exit:
if ($Help) {help;exit}

# Otherwise, filter input to output (add code in this loop as necessary to achieve desired result):
while (<STDIN>) {
   BLAT("At top of main loop.");
   print;
}
