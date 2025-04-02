#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# regexp-tester.pl
# Tests the regexps given by command-line arguments by applying them to the text coming in on STDIN.
# Written by Robbie Hatley.
# Edit history:
# Fri Dec 03, 2021: Wrote it.
# Wed Aug 23, 2023: Upgraded from "v5.32" to "v5.36". Reduced width from 120 to 110. Got rid of CPAN module
#                   "common::sense" (antiquated). Got rid of all prototypes. Now using signatures.
# Mon Aug 28, 2023: Improved argv. Got rid of "/o" on all instances of qr().
# Tue Aug 29, 2023: Changed all "$Db" to "$Db". Argument processing now set's $RegExp even if many args.
# Wed Aug 30, 2023: Got rid of a couple extra "say '';" (too many blank lines in output).
# Fri Oct 20, 2023: Got rid of "$RegExp". Instead, now using "@args" to contain multiple regexps to be tested.
#                   Input text is still via STDIN (redirect from file or pipe from echo).
# Mon Apr 22, 2024: Corrected errors in comments and help which erroneously stated that only one RegExp can be
#                   specified (actually, this program can now test many RegExps at once). Also got rid of
#                   subroutine "error()" as it's no-longer needed. (If no args, program simply does nothing.)
# Thu Aug 15, 2024: -C63; got rid of unnecessary "use" statements.
# Sat Mar 15, 2025: Modernized. Added debug. Removed "use RH::Util".
##############################################################################################################

use v5.36;
use utf8;

use Time::HiRes 'time';

use RH::Dir;
use RH::RegTest;

# ======= VARIABLES: =========================================================================================

# System Variables:
$" = ', ' ; # Quoted-array element separator = ", ".

# Global Variables:
our    $pname;                                 # Declare program name.
BEGIN {$pname = substr $0, 1 + rindex $0, '/'} # Set     program name.
our    $cmpl_beg;                              # Declare compilation begin time.
BEGIN {$cmpl_beg = time}                       # Set     compilation begin time.
our    $cmpl_end;                              # Declare compilation end   time.
INIT  {$cmpl_end = time}                       # Set     compilation end   time.

# Local variables:
# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $Debug     = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Verbose   = 0         ; # Be verbose?               bool      Shhhh!! Be quiet!!

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv ; # Process @ARGV.
sub test ; # Test RegExps.
sub help ; # Print help and exit.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Start execution timer:
   my $t0 = time;

   # Process @ARGV and set settings:
   argv;

   # Print program entry message if being terse or verbose:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      say STDERR "\nNow entering program \"$pname\" at timestamp $t0.";
      say STDERR '';
   }

   # Also print compilation time if being verbose:
   if ( 2 == $Verbose ) {
      printf(STDERR "Compilation time was %.3fms\n",1000*($cmpl_end-$cmpl_beg));
      say STDERR '';
   }

   # Print the values of all variables if debugging:
   if ( 1 == $Debug ) {
      say STDERR "pname     = $pname";
      say STDERR "cmpl_beg  = $cmpl_beg";
      say STDERR "cmpl_end  = $cmpl_end";
      say STDERR "Options   = (@Opts)";
      say STDERR "Arguments = (@Args)";
      say STDERR "Debug     = $Debug";
      say STDERR "Help      = $Help";
      say STDERR '';
   }

   # Test RegExps (or just print help and exit, if user wants help):
   $Help and help or test;

   # Stop execution timer:
   my $t1 = time;

   # Print exit message if being terse or verbose:
   if ( 1 == $Verbose || 2 == $Verbose ) {
      my $te = $t1 - $t0; my $ms = 1000 * $te;
      say    STDERR '';
      say    STDERR "Now exiting program \"$pname\" at timestamp $t1.";
      printf STDERR "Execution time was %.3fms.", $ms;
   }

   # Exit program, returning success code "0" to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

sub argv {
   # Get options and arguments:
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {           # For each element of @ARGV,
      /^--$/ && !$end        # "--" = end-of-options marker = construe all further CL items as arguments,
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
      /^-$s*h/ || /^--help$/    and $Help    = 1 ;
      /^-$s*e/ || /^--debug$/   and $Debug   = 1 ;
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0  ; # Default.
      /^-$s*t/ || /^--terse$/   and $Verbose =  1  ;
      /^-$s*v/ || /^--verbose$/ and $Verbose =  2  ;
   }

   # No processing needs to be done to @Args; it will be construed as a list of RegExps to be tested.

   # Return success code 1 to caller:
   return 1;
} # end sub argv

sub test {
   my @input_lines = <STDIN>;
   foreach my $RE ( @Args ) {
      my $tester = RH::RegTest->new($RE);
      foreach my $line ( @input_lines ) {
         $tester->match($line);
      }
   }
}

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "regexp-tester.pl". This program tests a list of regular expressions
   given as command-line arguments by matching text coming in on STDIN to those
   regexps.

   -------------------------------------------------------------------------------
   Command lines:

   regexp-tester.pl -h | --help          (to print this help and exit)
   regexp-tester.pl RegExp(s) < Input    (to test a regular expression)
   Input | regexp-tester.pl RegExp(s)    (to test a regular expression)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:                    Meaning:
   "-h" or "--help"           Print help and exit.
   "-e" or "--debug"          Print diagnostic information.
   "--"                       End of options; all further items are arguments.

   If you want to use an argument that looks like an option (say, you want to
   search for files which contain "--recurse" as part of their name), use a "--"
   option; that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   Arguments to this program should be Perl-Compliant Regular Expressions to be
   tested. This program will then test each of those regular expressions against
   each line of text coming in on STDIN. If no arguments are given, this program
   will do nothing. If no input is received from STDIN, this program will freeze
   until user types some input text followed by Ctrl-d to indicate end-of-input.

   -------------------------------------------------------------------------------
   Description of input:

   Input is via STDIN. The two easiest ways of providing input are:
   1. By pipe from echo:
      echo "$5di349skfg3785_-=+" | regexp-tester.pl '\pL{4}\d{4}'
   2. By redirect from file:
      regexp-tester.pl '\pL{4}\d{4}' < input_text.txt


   Happy regular-expression testing!

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
