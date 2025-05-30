#!/usr/bin/env perl

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# Welcome to script file "clone-directory-structure.pl".
# This program clones the directory structure of a source directory to an empty destination directory.
#
# Edit history:
# Thu Jun 25, 2015: Wrote first draft (of file "for-each-directory-in-tree.pl").
# Fri Jul 17, 2015: Upgraded for utf8.
# Sat Apr 16, 2016: Now using -CSDA.
# Sat Jan 02, 2021: Simplified and updated.
# Sat Jan 16, 2021: Refactored. Now using indented here documents.
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate; using "common::sense" and
#                   "Sys::Binmode".
# Thu Nov 25, 2021: Renamed to "for-each-directory-in-tree.pl" to avoid confusion with other programs.
#                   Shortened subroutine names. Added time stamping.
# Wed Feb 08, 2023: Forked a copy of "clone-directory-structure.pl" to "/d/rhe/PWCC/203/ch-2.pl".
# Wed Aug 14, 2024: Removed unnecessary "use" statements; -C63; width from 120 to 110.
# Tue Mar 04, 2025: Got rid of unnecessary encodings (conflict with "-C63").
# Fri May 02, 2025: Now using "utf8::all". Simplified shebang to "#!/usr/bin/env perl". Now using "carp" and
#                   "croak" from CPAN module "Carp". Changed bracing to C-style. Added more comments.
#                   Changed name of error-handling subroutine to "error".
##############################################################################################################

# ============================================================================================================
# PRELIMINARIES:

# Pragmas:
use v5.36;

# CPAN modules:
use utf8::all;
use Cwd::utf8;
use Time::HiRes 'time';
use Carp;

# RH modules:
use RH::Util;
use RH::Dir;

# ============================================================================================================
# VARIABLES:

our    $pname;                                 # Declare program name.
BEGIN {$pname = substr $0, 1 + rindex $0, '/'} # Set     program name.
my $db1        = 0  ; # Set to 1 to debug, 0 to not debug.
my $db2        = 0  ; # Set to 1 to debug, 0 to not debug.
my $db3        = 0  ; # Set to 1 to debug, 0 to not debug.
my $allow      = 0  ; # Set to 1 to allow non-empty destination directory.
my $srcedire        ; # Source      directory.
my $destdire        ; # Destination directory.
my $direcount  = 0  ; # Count of subdirectories created.

# ============================================================================================================
# SUBROUTINE PRE-DECLARATIONS:

sub argv     ; # Process @ARGV.
sub curdire  ; # Process current directory.
sub stats    ; # Print statistics.
sub error    ; # Print error message.
sub help     ; # Print help  message.

# ============================================================================================================
# MAIN BODY OF PROGRAM:

{ # begin main
   say STDERR "Now entering program \"$pname\".\n";
   my $t0 = time;
   argv;
   RecurseDirs {curdire};
   stats;
   my $t1 = time; my $ms = 1000 * ($t1 - $t0);
   printf STDERR "\nNow exiting program \"$pname\". Execution time was %.3fms.", $ms;
   exit 0;
} # end main

# ============================================================================================================
# SUBROUTINE DEFINITIONS:

sub argv {
   for ( my $i = 0 ; $i < @ARGV ; ++$i ) {
      $_ = $ARGV[$i];
      if (/^-[\pL]{1,}$/ || /^--[\pL\pM\pN\pP\pS]{2,}$/) {
         if (/^-h$/ || /^--help$/)  {help; exit;}
         if (/^-a$/ || /^--allow$/) {$allow = 1;}
         splice @ARGV, $i, 1;
         --$i;
      }
   }

   # Get number of non-option arguments:
   my $NA = scalar(@ARGV);

   # Croak if number of arguments is not 2:
   if ( 2 != $NA )                                 {error "Error: number of arguments is not two.          ";}

   # Store arguments in $srcedire and $destdire:
   $srcedire = $ARGV[0];
   $destdire = $ARGV[1];

   # Die if either does not exist,
   # or of either directory is not a directory,
   # or if either directory cannot be opened,
   # or if destination directory is not empty:
   if ( ! -e $srcedire )                           {error "Error: source directory doesn't exist.          ";}
   if ( ! -d $srcedire )                           {error "Error: source directory isn't a directory.      ";}
   if ( ! -e $destdire )                           {error "Error: destination directory doesn't exist.     ";}
   if ( ! -d $destdire )                           {error "Error: destination directory isn't a directory. ";}

   # OK, we have directories.
   # But can we actually open them?
   my $dhs = undef;
   my $dhd = undef;
   opendir($dhs, $srcedire) or                      croak "Error: couldn't open source directory.          ";
   opendir($dhd, $destdire) or                      croak "Error: couldn't open destination directory.     ";

   # If non-empty destination directory is
   # not being allowed, then enforce that here:
   if (!$allow) {
      my @dest = readdir $dhd;
      for (@dest) {
         if ('.' ne $_ && '..' ne $_)              {error "Error: destination directory isn't empty.       ";}
      }
   }

   # Close all directories for now:
   closedir $dhs;
   closedir $dhd;

   # IMPORTANT: Canonicalize $srcedire and $destdire
   # so that they become absolute instead of relative:
   my $strtdire = cwd;
   chdir $srcedire or                               croak "Error: couldn't chdir to source directory.      ";
   $srcedire = cwd;
   if ($db2) {
      say STDERR "source directory = $srcedire";
   }
   chdir $strtdire or                               croak "Error: couldn't chdir to starting directory.    ";
   chdir $destdire or                               croak "Error: couldn't chdir to destination directory. ";
   $destdire = cwd;
   if ($db2) {
      say STDERR "destination directory = $destdire";
   }

   # IMPORTANT: chdir back to srcedir,
   # else we'll start at the wrong place!!!
   chdir $srcedire or                               croak "Error: couldn't chdir back to source directory. ";

   return 1;
} # end sub argv

sub curdire {
   # Get and state current working directory:
   my $curdir = cwd;
   if ($db2) {say STDERR "\nDirectory # $direcount: \"$curdir\"\n";}

   # If current directory is the starting directory, just return:
   if ( $curdir eq $srcedire ) {return 1;}

   # Otherwise, make a mirror subdirectory for the other tree by snipping the left-most length($srcedire)
   # characters off of $curdir, then tacking the remainder to the right end of $destdire. For example, if
   # $srcedir is "/alpha/bravo", and $destdir is "/whiskey/xray", and $curdir is "/alpha/bravo/charly/delta",
   # then snip the "/alpha/bravo" from the left of $curdir, giving "/charly/delta", and tack that to the right
   # side of "/whisky/xray", giving "/whisky/xray/charly/delta":
   my $destsubd = $destdire . substr($curdir, length($srcedire));

   # If clone attempt for this subdirectory fails, don't croak, just warn about it:
   if (0 != system("mkdir -p '$destsubd'")) {
      warn "Warning: command failed: mkdir -p '$destsubd'\n";
   }

   # If attempt succeeded, brag about it:
   else {
      say "made new subdir '$destsubd'";
      ++$direcount;
   }

   # Return success code 1 to caller:
   return 1;
} # end sub curdire

sub stats {
   say STDERR "\n"
             ."Stats for running \"$pname\"\n"
             ."with  source    directory \"$srcedire\"\n"
             ."and destination directory \"$destdire\":\n"
             ."Cloned $direcount subdirs from source to destination.";
   return 1;
} # end sub stats

# Handle errors:
sub error ($msg) {
   print STDERR ((<<"   END_OF_ERROR") =~ s/^   //gmr);

   $msg

   This program takes 2 arguments, which must be directory paths, which may be
   either absolute or relative to current directory. The first path will be the
   source and the second will be the destination. The destination directory must
   be empty. This program will then clone the directory structure of the source
   to the destination, without copying any files.

   Run this program with a -h or --help option to get help.
   END_OF_ERROR
   exit 666;
} # end sub error

# Give help:
sub help
{
   print STDOUT ((<<"   END_OF_HELP") =~ s/^   //gmr);

   Welcome to "$pname", Robbie Hatley's nifty program for
   cloning the directory structure of a directory tree to an empty directory.
   This may be useful, for example, for setting-up a "mirror" drive to act as
   a backup for a main drive, to be used with "FreeFileSync", "TreeComp", or
   other such backup or synchronizing software

   Command lines:
   for-each-dir.pl [-h|--help]  (to print this help and exit)
   for-each-dir.pl srce dest    (to clone dir structure from srce to dest)

   Description of options:
   Option:                      Meaning:
   "-h" or "--help"             Print help and exit.
   "-a" or "--allow"            Allow non-empty destination directory.
   All other options are ignored.

   Description of arguments:
   This program takes exactly 2 arguments, which must be a source directory path
   followed by a destination directory path. Both paths may be either absolute
   (starting with "/") or relative to current directory (not starting with "/").
   Both directories must exist, and the destination directory must be empty.
   This program will then copy the directory structure from source to destination.
   No non-directory files will be copied.

   Also note that nothing on the "root" side of source or destination will be
   touched. For example, if source is "/a/b/c/d" and destination is "/x/y/z",
   then ONLY directories from inside "/a/b/c/d" (eg, "/a/b/c/d/e") will be
   copied, and contents will ONLY be added inside "/x/y/z" (eg,"/x/y/z/e").

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
