#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# move-files.pl
# Given the paths of two directories, Source and Destination, this program moves all files matching a regexp
# from Source to Destination, enumerating each file for which a file exists in Destination with the same name
# root. Optionally, this program can be instructed to NOT move any files for which duplicates exist in the
# destination, and/or change the name of the file to its own SHA1 hash.
#
# NOTE: You must have Perl and my RH::Dir module installed in order to use this script. Contact Robbie Hatley
# at <lonewolf@well.com> and I'll send my RH::Dir module to you.
#
# Edit history:
# Sat Jan 02, 2021: Wrote it.
# Sat Nov 20, 2021: Now using "common::sense" and "Sys::Binmode".
# Mon Nov 22, 2021: Now using "e" to avoid running file tests on unencoded paths.
# Mon Nov 22, 2021: Heavily refactored. Now using sub "move_files" in RH::Dir instead of local, and using
#                   a regular expression instead of a wildcard to specify files to move. Also, now subsumes
#                   the script "move-large-images.pl".
# Tue Nov 23, 2021: Fixed "won't handle relative directories" bug by using the chdir & cwd trick.
# Mon Mar 03, 2025: Got rid of "common::sense".
# Sat Apr 05, 2025: Now using "Cwd::utf8"; nixed "cwd_utf8".
# Sun May 04, 2025: Reverted to "utf8" and "Cwd" for Cygwin compatibility. Increased min ver to "v5.36".
#                   Nixed prototypes. Reduced width from 120 to 110.
##############################################################################################################

use v5.36;
use utf8;
use Cwd;
use Time::HiRes 'time';
use RH::Dir;

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv  ;
sub error ;
sub help  ;

# ======= PAGE-GLOBAL LEXICAL VARIABLES: =====================================================================

# Debugging:
my $db = 0; # Use debugging? (Ie, print diagnostics?)

# Settings:
my $src       = ''; # Srce directory.
my $dst       = ''; # Dest directory.
my $cur       = ''; # Curr directory.
my @MoveArgs  = (); # Arguments for move_files().

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   say "\nNow entering program \"" . get_name_from_path($0) . "\".\n";
   my $t0 = time;
   argv;
   if ($db)
   {
      warn "In main body of program \"move-files.pl\"\n",
           "Just ran argv().\n",
           "\$src = \"$src\"\n",
           "\$dst = \"$dst\"\n",
           "\@MoveArgs = \n",
           join("\n", @MoveArgs) . "\n";
      exit(84);
   }

   # Get FULLY-QUALIFIED versions of current, source, and destination directories:

   # Get current working directory:
   $cur = d getcwd;

   # CD to src, grab full path, then CD back to cur:
   chdir  e($src);
   $src = d(getcwd);
   chdir  e($cur);

   # CD to dst, grab full path, then CD back to cur:
   chdir  e($dst);
   $dst = d(getcwd);
   chdir  e($cur);

   # Move files:
   move_files($src, $dst, @MoveArgs);

   # We're done, so exit:
   my $t1 = time; my $te = $t1 - $t0;
   say "\nNow exiting program \"" . get_name_from_path($0) . "\". Execution time was $te seconds.\n";
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

sub argv {
   my @CLArgs = (); # Command-Line Arguments from @ARGV (not including options).

   if ($db) {
      warn "In program \"move-files.pl\", in sub argv().\n",
           "\@ARGV = \n",
           join("\n", @ARGV) . "\n";
   }

   foreach (@ARGV) {
      if (/^-[\pL\pN]{1}$/ || /^--[\pL\pM\pN\pP\pS]{2,}$/) {
            if ( '-h' eq $_ || '--help'   eq $_ ) {help; exit(777)     ;}
         elsif ( '-S' eq $_ || '--sl'     eq $_ ) {push @MoveArgs, 'sl'    ;}
         elsif ( '-s' eq $_ || '--sha1'   eq $_ ) {push @MoveArgs, 'sha1'  ;}
         elsif ( '-u' eq $_ || '--unique' eq $_ ) {push @MoveArgs, 'unique';}
         elsif ( '-l' eq $_ || '--large'  eq $_ ) {push @MoveArgs, 'large' ;}
      }
      else {
         push @CLArgs, $_;
      }
   }
   my $NA = scalar(@CLArgs);
   if ( $NA < 2 || $NA > 3 ) {error($NA); help; exit(666);}
   $src = $CLArgs[0];
   $dst = $CLArgs[1];
   if ( ! -e e($src) ) {die "Error: srce \"$src\" doesn't exist.    \n";}
   if ( ! -d e($src) ) {die "Error: srce \"$src\" isn't a directory.\n";}
   if ( ! -e e($dst) ) {die "Error: dest \"$dst\" doesn't exist.    \n";}
   if ( ! -d e($dst) ) {die "Error: dest \"$dst\" isn't a directory.\n";}
   if ( $NA > 2 ) {push @MoveArgs, 'regexp=' . $CLArgs[2];}

   if ($db) {
      warn "In move-files.pl, in argv, at bottom.\n",
           "scalar(\@CLArgs) = " . scalar(@CLArgs) . "\n",
           "\@CLArgs = \n",
           join("\n", @CLArgs) . "\n",
           "scalar(\@MoveArgs) = " . scalar(@MoveArgs) . "\n",
           "\@MoveArgs = \n",
           join("\n", @MoveArgs) . "\n";
   }

   return 1;
} # end sub argv

sub error ($NA) {
   print ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   Error: \"move-files.pl\" takes 2 mandatory arguments (which must be paths to
   a source directory and a destination directory), and 1 optional argument
   (which, if present, must be a regular expression specifying which files to
   move), but you typed $NA arguments. Help follows:
   END_OF_ERROR
   return 1;
} # end sub error

sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "move-files.pl", Robbie Hatley's nifty file-moving utility.
   This program moves all files matching a regexp from a source directory
   (let's call it "dir1") to a destination directory (let's call it "dir2"),
   enumerting each file if necessary, but skipping all "Thumbs*.db",
   "pspbrwse*.jbf", and "desktop*.ini" files. Optionally, this program can
   skip any files in dir1 for which duplicates exist in dir2, and/or rename
   the moved files' name roots to the files' own SHA1 hashes.

   Command line:
   move-files.pl [-h|--help]                    (to print this help and exit)
   move-files.pl [options] dir1 dir2 [regexp]   (to move files)

   Description of options:
   Option:             Meaning:
   "-h" or "--help"    Print help and exit.
   "-S" or "--sl"      Shorten names for when processing Windows Spotlight images.
   "-s" or "--sha1"    Change name root of each file to its own hash.
   "-u" or "--unique"  Don't copy files for which duplicates exist in destination.
   "-l" or "--large"   Move only large image files (W=1200+, H=600+).
   All other options will be ignored.

   Description of arguments:
   "move-files.pl" takes two mandatory arguments which must be paths to existing
   directories; dir1 is the source directory and dir2 is the destination
   directory.

   Additionally, "move-files.pl" can take a third, optional argument which, if
   present, must be a Perl-Compliant Regular Expression specifying which items
   to process. To specify multiple patterns, use the | alternation operator.
   To apply pattern modifier letters, use an Extended RegExp Sequence.
   For example, if you want to search for items with names containing "cat",
   "dog", or "horse", title-cased or not, you could use this regexp:
   '(?i:c)at|(?i:d)og|(?i:h)orse'
   Be sure to enclose your regexp in 'single quotes', else BASH may replace it
   with matching names of entities in the current directory and send THOSE to
   this program, whereas this program needs the raw regexp instead.

   Also note that this program cannot act recursively; it moves files only from
   the root level of dir1 to the root level of dir2; the contents of any
   subdirectories of dir1 or dir2 are not touched.

   Happy file moving!
   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
