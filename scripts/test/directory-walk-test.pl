#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# directory-walk-test.pl
##############################################################################################################

use v5.36;
use utf8;

use Cwd           qw( cwd getcwd   );
use Time::HiRes   qw( time         );
use Data::Dumper  qw( :DEFAULT     );

use RH::Dir;

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
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv       ; # Process @ARGV and set settings.
sub curdire    ; # Process current directory.
sub help       ; # Print help.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   my $t0 = time;
   argv;
   say STDERR "\nNow entering program \"$pname\" at timestamp $t0.";
   say STDERR '';
   printf(STDERR "Compilation time was %.3fms\n",1000*($cmpl_end-$cmpl_beg));
   say STDERR '';
   say STDERR "pname     = $pname";
   say STDERR "cmpl_beg  = $cmpl_beg";
   say STDERR "cmpl_end  = $cmpl_end";
   say STDERR "Options   = (@Opts)";
   say STDERR "Arguments = (@Args)";
   say STDERR "Help      = $Help";
   say STDERR '';
   $Help and help or RecurseDirs {curdire};
   my $t1 = time;
   my $te = $t1 - $t0; my $ms = 1000 * $te;
   say    STDERR '';
   say    STDERR "Now exiting program \"$pname\" at timestamp $t1.";
   printf STDERR "Execution time was %.3fms.", $ms;
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS =============================================================================

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
      /^-$s*h/ || /^--help$/    and $Help    =  1  ;
   }

   # Ignore all arguments.

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   # Announce current working directory:
   say d(getcwd);
   # Return success code 1 to caller:
   return 1;
} # end sub curdire

sub help
{
   print STDERR ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "directory-walk-test.pl", Robbie Hatley's Nifty directory-walk
   testing utility. This lists the paths of all directories in the current tree.

   -------------------------------------------------------------------------------
   Command lines:

   directory-walk-test.pl [-h | --help]   (to print this help and exit)
   directory-walk-test.pl [options]       (to list all subdirs)

   -------------------------------------------------------------------------------
   Description of options:

   Option:             Meaning:
   -h or --help        Print help and exit.
         --            End of options (all further CL items are arguments).

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -vr to verbosely and recursively process items.

   If multiple conflicting separate options are given, later overrides earlier.
   If multiple conflicting single-letter options are piled after a single hyphen,
   the result is determined by this descending order of precedence: heiabdfrlvtq.

   If you want to use an argument that looks like an option (say, you want to
   search for files which contain "--recurse" as part of their name), use a "--"
   option; that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of arguments:

   This program ignores all arguments.


   Happy directory listing!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
