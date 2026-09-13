#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# substitute-dangerous.pl
# Runs an s/pattern/replacement/options substitution on lines of text.
# Input of pattern, replacement, and options is via command-line arguments.
# Input of text being processed is via STDIN, pipe, or redirect.
# Output is to STDOUT. (Doesn't alter input.)
# Note: This version allows code and captures in replacements; use "substitute-safe.pl" for a safer version.
#
# Written by Robbie Hatley in December 2014 (exact date unknown).
#
# Edit history:
# ??? Dec ??, 2014: Wrote it sometime in December 2014.
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 02, 2016: Added help. Added "#!/usr/bin/env -S perl -CSDA".
# Tue Nov 09, 2021: Refreshed shebang, colophon, and boilerplate.
# Wed Dec 08, 2021: Reformatted title block.
# Sat Aug 03, 2024: Reduced width from 120 to 110; upgraded from "v5.32" to "v5.36"; added "use utf8";
#                   got rid of "use common::sense"; got rid of "use Sys::Binmode".
# Fri Sep 11, 2026: Split from "substitute.pl" to "substitute-safe.pl" and "substitute-dangerous.pl".
#                   Using string eval in this "dangerous" version. Now allowing all flags.
# Sat Sep 12, 2026: Made the "dangerous" and "safe" versions of this script as identical as possible
#                   while still retaining their unique attributes ("flexible-but-dangerous" vs "safe").
##############################################################################################################

use v5.42;
use utf8::all;
use re 'eval';

# ======= VARIABLES: =========================================================================================

my @Opts = ();
my @Args = ();
my $Debg =  0;
my $Verb =  0;
my $Targ = '';
my $Repl = '';
my $Flgs = '';
my $Rflg = '';
my $Sflg = '';
my $Regx = '';

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv;
sub help;

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Process arguments:
   argv;

   # Say values of variables if being verbose:
   if ( $Verb ) {
      say STDERR
         "Targ = $Targ\n"
        ."Repl = $Repl\n"
        ."Flgs = $Flgs\n"
        ."Rflg = $Rflg\n"
        ."Sflg = $Sflg\n"
        ."Regx = $Regx\n";
   }

   # Print substituted versions of all lines from STDIN to STDOUT:
   my $Cmnd = "s/$Regx/$Repl/$Sflg";
   while (<STDIN>) {
      if ( $Debg ) {
         warn "Command which would have been executed = \"$Cmnd\".\n";
         next;
      }
      eval $Cmnd; if ( $@ ) {warn "Error executing substitution: \"$@\". Command was \"$Cmnd\".\n";}
      print;
   }

   # Exit program, returning success code 0 to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV:
sub argv {
   # Get options and arguments:
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   # Riffle through @ARGV, copying each element (except for a possible '--') to either $Opts or $Args:
   for ( @ARGV ) {
      # If we see '--', set $end to 1 (don't push '--' to @Opts or @Args):
      if ( /^--$/ ) {$end = 1;}
      # Else if we're not yet at end-of-options, and we see an option, push it to @Opts:
      elsif ( !$end && ( /^-(?!-)$s+$/ ||  /^--(?!-)$d+$/ ) ) {push @Opts, $_;}
      # Else push current item to @Args:
      else {push @Args, $_;}
   }

   # Process options:
   for ( @Opts ) {
      /^-$s*h/ || /^--help$/    and help and exit;
      /^-$s*e/ || /^--debug$/   and $Debg    =  1  ;
      /^-$s*v/ || /^--verbose$/ and $Verb    =  2  ;
   }

   # Process arguments:
   my $num_args = scalar @Args;
   if (2 == $num_args) {
      $Targ = $Args[0];
      $Repl = $Args[1];
      $Flgs = '';
   }
   elsif (3 == $num_args) {
      $Targ = $Args[0];
      $Repl = $Args[1];
      $Flgs = $Args[2];
   }
   else {
      die
      "Error: substitute.pl requires either two arguments (pattern, replacement)\n".
      "or three arguments (pattern, replacement, options).\n";
   }

   # Don't disallow "/e" modifier.
   # Let user run code.
   # If it malfunctions, that's hir responsibility.
   # This program is like a revving chainsaw, not a butter knife.
   # It's up to each user to learn how to use it safely.
   # It's not my job to play nanny.

   # Separate substitution flags from regexp flags:
   $Rflg = join '', grep { !/[cegr]/ } split //, $Flgs;
   $Sflg = join '', grep {  /[cegr]/ } split //, $Flgs;

   # Compile regexp, with regexp flags:
   $Regx = eval { qr#(?$Rflg:$Targ)# };
   if ( $@ ) {die "Error: Invalid regular expression.\n$@\n";}

   # If we didn't die, return success code 1 to caller:
   return 1;
} # end sub argv

# Give help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "substitute.pl". Like the Perl s/// operator (which it uses),
   this program performs regular-expression substitution on whatever lines
   of text are fed to it via STDIN. The output is fed to STDOUT. The input
   is not altered (ie, this program is a "filter").

   This program examines each line of text coming in on STDIN, looking for
   matches to the regular expression in arg1, and substituting the replacement
   pattern in arg2 for those matches, while obeying the s/// flags given via arg3
   (if present).

   The original text coming in via STDIN is not altered.

   Output is written to STDOUT.

   Captures and code execution in replacements are allowed, so this program is
   dangerous. For a safer program, use my "substitute-safe.pl" instead.

   All modifiers are allowed. Yes, even "/e" is allowed, so you can execute
   arbitrary snippets of Perl code. The outcome is your responsibility.

   However, while not disallowed, some modifiers will do nothing, others will
   cause warnings to be printed, one will stop this program from performing any
   substitutions, and some will cause this program to crash. For example:
   "/r" discards the substitution.
   "/o" does nothing in the context of this program.
   "/c" does nothing in the context of this program.
   "/y", "/z", "/茶", etc, crash the program because they're invalid modifiers.

   So it's YOUR responsibility to learn what the valid Perl pattern-matching-
   operator modifier letters are, and what each does, and which are appropriate
   for a substitution program using Perl's s/// operator.

   -------------------------------------------------------------------------------
   Command lines:

   substitute-dangerous.pl [-h | --help]               (to get help)
   substitute-dangerous.pl [options] arg1 arg2 [arg3]  (to substitute)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Emulate substitutions.
   -v or --verbose    Print diagnostics.
         --           End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -ev to emulate substitutions and print diagnostics.

   If you want to use an argument that looks like an option (say, you want to
   replace "-e" with "-f" globally), use a "--" option; that will force all
   command-line entries to its right to be considered "arguments" rather than
   "options".

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   In addition to options, this program takes 2 or 3 arguments:
   Cmnd Line:                               Meaning:
   substitute-dangerous.pl arg1 arg2        s/arg1/arg2/
   substitute-dangerous.pl arg1 arg2 arg3   s/arg1/arg2/arg3


   Happy substituting!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
