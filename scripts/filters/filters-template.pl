#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# filters-template.pl
# This file serves as a template for making new "filters" text-filtering scripts. This template is not
# dependent on "utf8::all" or "Cwd::utf8", is not dependent on having a copy of "env" installed which
# accepts the "-S" flag, is compatible with all Perl versions, and is compatible with Cygwin. This template
# expects UTF-8-tranformed Unicode as STDIN input and emits UTF-8-tranformed Unicode as output.
#
# Edit history:
# Sat Nov 01, 2025: Wrote first draft.
##############################################################################################################

##############################################################################################################
# myprog.pl
# Twiddles libokods on ungish iblkaubs.
# Written by Robbie Hatley.
# Edit history:
# Mon Dec 01, 2025: Wrote it.
##############################################################################################################

# Pragmas:
use v5.40;

# Essential CPAN Modules:
use utf8::all;
use Cwd::utf8;
use Time::HiRes qw( time );

# Extra CPAN Modules:
use Scalar::Util qw( looks_like_number reftype );
use Regexp::Common;
use Unicode::Normalize;
use Unicode::Collate;
use MIME::QuotedPrint;

# Essential RH Modules:
use RH::Dir;        # Recurse directories; get list of file-info packets for names matching a regexp; etc.
use RH::Util;       # Unbuffered single-keystroke inputs; etc.

# Extra RH modules:
use RH::Math;       # Math routines.
use RH::RegTest;    # Test regular expressions.
use RH::WinChomp;   # "chomp" for Microsoft Windows.

# ======= VARIABLES: =========================================================================================

# ------- System Variables: ----------------------------------------------------------------------------------

$" = ', ' ; # Quoted-array element separator = ", ".

# ------- Global Variables: ----------------------------------------------------------------------------------

our    $pname;                                 # Declare program name.
BEGIN {$pname = substr $0, 1 + rindex $0, '/'} # Set     program name.
our    $cmpl_beg;                              # Declare compilation begin time.
BEGIN {$cmpl_beg = time}                       # Set     compilation begin time.
our    $cmpl_end;                              # Declare compilation end   time.
INIT  {$cmpl_end = time}                       # Set     compilation end   time.

# ------- Local variables: -----------------------------------------------------------------------------------

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my $OriDir    = cwd       ; # Original directory.       cwd       Directory on program entry.
my $Debug     =  0        ; # Print diagnostics?        bool      Don't print diagnostics.

# ======= SUBROUTINE PREDECLARATIONS: ========================================================================

sub argv;
sub filter;
sub BLAT;
sub help;

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main

   # Process @ARGV:
   argv;

   # Filter input to output:
   while (<>) {
      filter;
      print;
   }

} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV:
sub argv {
   # Declare and define certain variables we'll need:
   my $e = 0;                # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   my @opts = ();            # options

   # Pull all options OUT of @ARGV and put them in @opts instead:
   for ( my $i = 0 ; $i <= $#ARGV ; ++$i ) {
      # If current item is end-of-options marker, remove it from @ARGV, set "$e", and consider all remaining
      # contents of @ARGV to be "arguments" rather than "options":
      if ( '--' eq $ARGV[$i] ) {
         $e = 1;
         splice @ARGV, $i, 1;
         --$i;
      }
      # Else if current item is an "option", remove it from @ARGV and push it to @opts:
      elsif ( !$e && ( $ARGV[$i] =~ /^-(?!-)$s+$/ || $ARGV[$i] =~ /^--(?!-)$d+$/ ) ) {
         push @opts, splice @ARGV, $i, 1;
         --$i;
      }
      # Otherwise, this item is an argument, so leave it in @ARGV:
      else {
         ; # Do nothing.
      }
   }
   # @ARGV now contains NO options; if any items remain, they will be construed by <> as being input files.

   # Process options:
   for ( @opts ) {
      /^-$s*h$s*$/ || /^--help$/    and help and exit(0)                        ;
      /^-$s*e$s*$/ || /^--emulate$/ and $Debug = 1 and RH::Dir::rhd_debug('on') ;
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Filter input line:
sub filter {
   BLAT("At top of filter. \$_ = $_");
           #ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz
   y/A-Za-z/PZWLRKMQTOFDGUJAHEYINXCVSBgqzmlpaihwredsxfbknvytjouc/;
   BLAT("At bottom of filter. \$_ = $_");
}

# Print messages only if debugging:
sub BLAT ( $string ) {
   if ($Debug) {print STDERR "$string\n"}
}

# Print help:
sub help {
   print STDERR ((<<"   END_OF_HELP") =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "$pname". This program does blah blah blah to input text
   and outputs the result, without altering the input text. All input is via
   STDIN and all output is via STDOUT. Use of pipes and/or redirects to channel
   text flow is highly recommended.

   -------------------------------------------------------------------------------
   Command lines:

   $pname -h | --help                      (to print this help and exit)
   $pname [options] [Arg1] [Arg2] [Arg3]   (to [perform function] )

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
