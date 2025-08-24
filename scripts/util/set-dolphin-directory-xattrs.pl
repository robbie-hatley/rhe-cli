#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# "set-dolphin-directory-xattrs.pl"
# For the current directory (and all subdirectories if a -r or --recurse option is used), set all xattrs
# to "icons" if pictures are present, else "details".
#
# Written by Robbie Hatley, beginning on Monday March 13, 2023.
#
# Edit history:
# Mon Mar 13, 2023: Wrote first draft.
# Tue Mar 14, 2023: Expanded from jpg to (jpg,bmp,png,gif) and make extensions case-insensitive.
# Sun Mar 19, 2023: Made "error" a "do just one thing" function, fixed "error" and "help" duplication bug,
#                   removed all "prototypes", added "signature" to "error", and added "use utf8"
#                   (necessary due to removal of "use common::sense").
# Mon Mar 20, 2023: Renamed from "dolphin-ctrl1.pl" to "repair-dolphin-directory-files.pl". Changed program
#                   semantics so that it doesn't just paste a ctrl-1 file to "picture" directories, but also
#                   pastes a ctrl-3 file to non-picture directories.
# Thu Aug 31, 2023: Fixed excalibur-vs-Excalibur bug. (My main computer is "Excalibur", not "excalibur".)
#                   Reduced width from 120 to 110. Clarified sub argv().
#                   Got rid of "/...|.../" in favor of "/.../ || /.../" (speeds-up program).
#                   Simplified way in which options and arguments are printed if debugging.
#                   Removed "$" = ', '" and "$, = ', '". Got rid of "/o" from all instances of qr().
#                   Changed all "$db" to $Db". Debugging now simulates renames instead of exiting in main.
#                   Removed "no debug" option as that's already default in all of my programs.
#                   Variable "$Verbose" now means "print per-file info", and default is to NOT do that.
#                   STDERR = "stats and serious errors". STDOUT = "files erased/copied, and dirs if verbose".
# Thu Aug 15, 2024: -C63; got rid of unnecessary "use" statements.
# Sun Mar 16, 2025: Minor tweaks to formatting, comments, and help.
# Sun Aug 24, 2025: Split this program off from "replace-dolphin-directory-files.pl" due to changes in how
#                   Dolphin does things.
##############################################################################################################

use v5.36;
use utf8;

use Cwd 'getcwd';
use Time::HiRes 'time';
use Sys::Hostname;

use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub curdire ; # Process current directory.
sub stats   ; # Print statistics.
sub error   ; # Handle errors.
sub help    ; # Print help and exit.

# ======= VARIABLES: =========================================================================================

# Settings:     Default:   # Meaning of setting:          Range:    Meaning of default:
my $Db        = 0        ; # Debug (print diagnostics)?   bool      Don't print diagnostics.
my $RegExp    = qr/^.+$/ ; # Regular Expression.          regexp    Process all directory names.
my $Recurse   = 0        ; # Recurse subdirectories?      bool      Don't recurse.
my $Verbose   = 0        ; # Be wordy?                    bool      Be quiet.

# Counters:
my $direcount = 0 ; # Count of directories processed by curdire().
my $erascount = 0 ; # Count of ".directory" files erased.
my $erfacount = 0 ; # Count of failed erasure attempts.
my $copycount = 0 ; # Count of ".directory" files copied.
my $cofacount = 0 ; # Count of failed copy attempts.
my $simecount = 0 ; # Count of simulated file erasures.
my $simccount = 0 ; # Count of simulated file copies.


# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Set start time, process @ARGV, and print entry message:
   my $t0 = time;
   argv;
   my $pname = get_name_from_path($0);
   say STDERR '';
   say STDERR "Now entering program \"$pname\".";
   say STDERR "\$Db      = $Db";
   say STDERR "\$RegExp  = $RegExp";
   say STDERR "\$Recurse = $Recurse";
   say STDERR "\$Verbose = $Verbose";

   # Run sub curdire() for desired directories:
   $Recurse and RecurseDirs {curdire} or curdire;

   # Print closing newline if we've just been printing $direcount repeatedly on top of itself:
   print STDOUT "\n" if !$Verbose && !$Db;

   # Finally, print stats and exit message, including run time:
   stats;
   my $te = time - $t0;
   say STDERR "\nNow exiting program \"$pname\".\nExecution time was $te seconds.";
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV :
sub argv {
   # Get options and arguments:
   my @opts = ();             # options
   my @args = ();             # arguments
   my $end = 0;               # end-of-options flag
   my $s = '[a-zA-Z0-9]';     # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]';  # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {
      /^--$/                  # "--" = end-of-options marker = construe all further CL items as arguments,
      and $end = 1            # so if we see that, then set the "end-of-options" flag
      and next;               # and skip to next element of @ARGV.
      !$end                   # If we haven't yet reached end-of-options,
      && ( /^-(?!-)$s+$/      # and if we get a valid short option
      ||   /^--(?!-)$d+$/ )   # or a valid long option,
      and push @opts, $_      # then push item to @opts
      or  push @args, $_;     # else push item to @args.
   }

   for ( @opts ) {
      /^-$s*h/ || /^--help$/    and help and exit 777 ;
      /^-$s*e/ || /^--debug$/   and $Db      =  1     ;
      /^-$s*q/ || /^--quiet$/   and $Verbose =  0     ;
      /^-$s*v/ || /^--verbose$/ and $Verbose =  1     ;
      /^-$s*l/ || /^--local$/   and $Recurse =  0     ;
      /^-$s*r/ || /^--recurse$/ and $Recurse =  1     ;
   }
   if ( $Db ) {
      say STDERR '';
      say STDERR "\$opts = (", join(', ', map {"\"$_\""} @opts), ')';
      say STDERR "\$args = (", join(', ', map {"\"$_\""} @args), ')';
   }

   # Process arguments:
   my $NA = scalar(@args);     # Get number of arguments.
   $NA >= 1                    # If number of arguments >= 1,
   and $RegExp = qr/$args[0]/; # set $RegExp.
   $NA >= 2 && !$Db            # If number of arguments >= 2 and we're not debugging,
   and error($NA)              # print error message,
   and help                    # and print help message,
   and exit 666;               # and exit, returning The Number Of The Beast.

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# Process current directory:
sub curdire {
   # Get current working directory:
   my $cwd = d getcwd;

   # Return 1 if this directory doesn't match our regexp:
   return 1 if $cwd !~ m/$RegExp/;

   # If we get to here, increment directory counter:
   ++$direcount;

   # Announce directory:
   if ( $Verbose || $Db ) {
      say STDOUT "\nDirectory # $direcount: $cwd\n";
   }
   else {
      if ( 1 == $direcount ) {
         printf STDOUT "\nDirectory # %6d", $direcount;
      }
      else {
         printf STDOUT "\b\b\b\b\b\b%6d", $direcount;
      }
   }

   # Get ref to array of file-info packets for all regular files in in $cwd matching $RegExp:
   my $curdirfiles = GetFiles($cwd, 'F', $RegExp);

   # Riffle through the files and count how many pictures are here:
   my $pics = 0;
   foreach my $file ( @{$curdirfiles} ) {
      my $s = get_suffix($file->{Name});
      # Count pictures:
      if (     $s eq '.jpg'  || $s eq '.jpeg' || $s eq '.bmp'  || $s eq '.png'
            || $s eq '.apng' || $s eq '.gif'  || $s eq '.tif'  || $s eq '.tiff' ) {
         ++$pics;
      }
   }

   # Set view:
   my $view = (($pics>0)?0:1);
   my $command = "setfattr -h -n user.kde.fm.viewproperties#1 -v \"[Dolphin]\012Version=4\012ViewMode=$view\012\" .";

   # If 1-or-more pictures exist in this directory, set view to "Icons", else "Details":
   if ( 0 == system(e($command)) ) {
      ++$copycount;
      say STDOUT "Set view to $view." if $Verbose;
   }
   else {
      ++$cofacount;
      say STDOUT "Failed to view to $view." if $Verbose;
   }

   # We're done, so return 1:
   return 1;
} # end sub curdire

# Print statistics for this program run:
sub stats
{
   say STDERR '';
   say STDERR 'Statistics for this directory tree:';
   say STDERR "Found $direcount directories matching RegExp.";
   say STDERR "Set $copycount view settings.";
   say STDERR "Failed $cofacount attempts to set view settings.";
   return 1;
} # end sub stats

# Handle errors:
sub error ($err_msg)
{
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: you typed $err_msg arguments, but this program takes at most 1 argument,
   which, if present, must be a Perl-Compliant Regular Expression specifying
   which directory entries to process. Help follows:
   END_OF_ERROR
} # end sub error

# Print help:
sub help
{
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "set-dolphin-directory-xattrs.pl". This program alters metadata of
   directories so that Dolphin (KDE's main file-manager program) will use "Icons"
   view if one-or-more image files exist in a directory, else will use "Details"
   view.

   Warning: If you're not using "Dolphin" as your primary file manager, then this
   program will be useless to you, so don't waste your time with it.

   -------------------------------------------------------------------------------
   Command lines:

   set-dolphin-directory-xattrs.pl -h | --help            (to print help and exit)
   set-dolphin-directory-xattrs.pl [options] [arguments]  (to set view)

   -------------------------------------------------------------------------------
   Description of options:

   Option:              Meaning:
   -h or --help         Print this help and exit.
   -e or --debug        Print diagnostics and simulate file copies.
   -q or --quiet        Don't print per-file info.                  (DEFAULT)
   -v or --verbose      Do    print per-file info.
   -l or --local        Don't recurse subdirectories.               (DEFAULT)
   -r or --recurse      Do    recurse subdirectories.

   Multiple single-letter options may be piled-up after a single hyphen.
   For example, use -vr to verbosely and recursively process items.

   If multiple conflicting separate options are given, later overrides earlier.
   If multiple conflicting single-letter options are piled after a single hyphen,
   the result is determined by this descending order of precedence: herlvq.

   If you want to use an argument that looks like an option (say, you want to
   search for dirs which contain "--recurse" as part of their name), use a "--"
   option; that will force all command-line entries to its right to be considered
   "arguments" rather than "options".

   All options not listed above are ignored.

   -------------------------------------------------------------------------------
   Description of arguments:

   In addition to options, this program can take one optional argument which,
   if present, must be a Perl-Compliant Regular Expression specifying which
   directories to process. To specify multiple patterns, use the | alternation
   operator. To apply pattern modifier letters, use an Extended RegExp Sequence.
   For example, if you want to search for items with names containing "cat",
   "dog", or "horse", title-cased or not, you could use this regexp:
   '(?i:c)at|(?i:d)og|(?i:h)orse'
   Be sure to enclose your regexp in 'single quotes', else BASH may replace it
   with matching names of entities in the current directory and send THOSE to
   this program, whereas this program needs the raw regexp instead.

   Happy picture viewing!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
__END__
