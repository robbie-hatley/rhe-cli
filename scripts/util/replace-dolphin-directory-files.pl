#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# "replace-dolphin-directory-files.pl"
# For the current directory (and all subdirectories if a -r or --recurse option is used), replace all
# Dolphin ".directory" files with versions which are appropriate for the contents of the directory.
# Makes sure that directories which contain 1-or-more picture files (jpg, jpeg, bmp, png, apng, gif, tif,
# tiff) have a "thumbnails" or ctrl-1 ".directory" file, and all other directories should have a "details"
# or ctrl-3 ".directory" file.
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

# Paths to known ctrl-1 and ctrl-3 ".directory" files:
my $hostname = hostname();
my $ctrl_1_path;
my $ctrl_3_path;

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

   # Select appropriate "exemplars" of the "pictures" and "general" versions of the file ".directory".
   # Path "$ctrl_1_path" will be for   pictures  and will be equivalent to manually pressing Ctrl-1.
   # Path "$ctrl_3_path" will be for general use and will be equivalent to manually pressing Ctrl-3.
   if ( 'Excalibur' eq $hostname ) {
      $ctrl_1_path = '/home/aragorn/Data/Ulthar/OS-Resources/Background-Pictures/Scenic/.directory';
      $ctrl_3_path = '/home/aragorn/Data/Celephais/Captain’s-Den/FFS-Profiles/.directory';
   }
   elsif ( 'optiplex-major' eq $hostname ) {
      $ctrl_1_path = '/home/arthur/Aranath/OS-Resources/Background-Pictures/.directory';
      $ctrl_3_path = '/home/arthur/Belequenta/rhe/scripts/util/.directory';
   }
   else {
      die "Not set-up for this host.\n$!\n";
   }

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

   # Return 1 if we're in one of our "exemplar" directories:
   if ( 'Excalibur' eq $hostname ) {
      if ( '/home/aragorn/Data/Ulthar/OS-Resources/Background-Pictures/Scenic' eq $cwd ) {
         return 1;
      }
      if ( '/home/aragorn/Data/Celephais/Captain’s-Den/FFS-Profiles' eq $cwd ) {
         return 1;
      }
   }

   elsif ( 'optiplex-major' eq $hostname ) {
      if ( '/home/arthur/Aranath/OS-Resources/Background-Pictures' eq $cwd ) {
         return 1;
      }
      if ( '/home/arthur/Belequenta/rhe/scripts/util' eq $cwd ) {
         return 1;
      }
   }

   # Die if host is unknown:
   else {
      die "Error in rdd, in curdire(): invalid host.\n$!\n";
   }

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

   # Riffle through the files, count how many pictures are here, and get rid of
   # any old (possibly enumerated or corrupted) ".directory" files":
   my $pics = 0;
   foreach my $file ( @{$curdirfiles} ) {
      my $p = $file->{Path};
      my $n = $file->{Name};
      my $r = get_prefix($n);
      my $s = get_suffix($n);
      say STDERR "In rdd, in curdire(), in file loop; path = $p" if $Db;
      say STDERR "In rdd, in curdire(), in file loop; name = $n" if $Db;
      say STDERR "In rdd, in curdire(), in file loop; pref = $r" if $Db;
      say STDERR "In rdd, in curdire(), in file loop; suff = $s" if $Db;
      if ( $file->{Name} =~ m/^(?:-\(\d{4}\))*\.directory$/ ) {
         if ( $Db ) {
            ++$simecount;
            say STDOUT "Simulation: would have erased \"$file->{Path}\"." if $Verbose;
         }
         else {
            if ( unlink(e($file->{Path})) ) {
               ++$erascount;
               say STDOUT "erased \"$file->{Path}\"" if $Verbose;
            }
            else {
               ++$erfacount;
               say STDOUT "Failed to erase \"$file->{Path}\"" if $Verbose;
            }
         }
      }
      if (     $s eq '.jpg'  || $s eq '.jpeg' || $s eq '.bmp'  || $s eq '.png'
            || $s eq '.apng' || $s eq '.gif'  || $s eq '.tif'  || $s eq '.tiff' ) {
         ++$pics;
      }
   }

   # If 1-or-more pictures exist in this directory, paste a ctrl-1 ".directory" file here:
   my $spath = $pics > 0 ? $ctrl_1_path : $ctrl_3_path;
   my $dpath = path($cwd, ".directory");
   if ( $Db ) {
      ++$simccount;
      say STDOUT "Simulation: would have copied \"$spath\" to \"$dpath\".";
   }

   # Otherwise, paste a ctrl-3 ".directory" file here:
   else {
      if ( 0 == system(e("cp '$spath' '$dpath'")) ) {
         ++$copycount;
         say STDOUT "Copied .directory file from \"$spath\" to \"$dpath\"." if $Verbose;
      }
      else {
         ++$cofacount;
         say STDOUT "Failed to copy .directory file from \"$spath\" to \"$dpath\"." if $Verbose;
      }
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
   say STDERR "Erased $erascount old, enumerated, or corrupted \".directory\" files.";
   say STDERR "Failed $erfacount erasure attempts.";
   say STDERR "Copied $copycount new \".directory\" files.";
   say STDERR "Failed $cofacount copy attempts.";
   say STDERR "Simulated $simecount file erasures.";
   say STDERR "Simulated $simccount file copies.";
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

   Welcome to "repair-dolphin-directory-files.pl". This program pastes replaces
   all existing Dolphin ".directory" files in the current directory (and all
   subdirectories if a -r or --recurse option is used) with an appropriate
   ".directory" file depending on whether or not pictures are present.

   If 1-or-more picture files are present, a "Ctrl-1" .directory file is copied;
   this will cause picture files in Dolphin to be displayed as thumbnails.

   If    no     picture files are present, a "Ctrl-3" .directory file is copied;
   this will put Dolphin in "Details" mode for the current directory.

   WARNING: To get this program to work for you, you'll have to alter its source
   code to specify your own allowed host names (the computers you want to run this
   on) and exemplar directories (one directory with a ".directory" file set for
   "non-picture" contents,  and  one directory with a ".directory" file set for
   "picture" contents). But run my program
   "refresh-dolphin-directory-file-dates.pl" on your exemplar directories first,
   else this program may not work, because Dolphin ignores ".directory" files that
   haven't been updated in a long time.

   WARNING: If you're not using "Dolphin" as your primary file manager, then this
   program will be useless to you, so don't waste your time with it.

   -------------------------------------------------------------------------------
   Command lines:

   program-name.pl -h | --help            (to print help and exit)
   program-name.pl [options] [arguments]  (to copy ".directory" )

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
