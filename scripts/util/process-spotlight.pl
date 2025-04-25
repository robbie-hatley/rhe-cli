#!/usr/bin/env perl

# This is a 120-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय. 看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# process-spotlight.pl
# Processes images scavenged from MS Win 10 Spotlight.
#
# Edit history:
# Sat Feb 01, 2020: Wrote first draft. Stub.
# Mon Mar 23, 2020: Wrote second draft. Testing verify_directory.
# Sun Apr 05, 2020: Now fully functional.
# Sat Jun 13, 2020: Now prefering Windows Spotlight file names over gibberish names.
# Tue Jun 23, 2020: Fixed some errors in comments; simplified code.
# Sat Sep 05, 2020: Removed -CSDA from shebang for now because it was causing a "too late"
#                   error, due to the fact that I'm now invoking this script  via a wrapper
#                   shell script. But that's fine because the -CSDA is now in the perl
#                   invocation line in the wrapper.
# Thu Sep 10, 2020: Put -CSDA back into the shebang, because I'm no longer invoking this
#                   script from a shell-script wrapper. Also, changed "copy" to "cp" because
#                   copy killed timestamps. Also changed "cp -p" to "cp --preserve=timestamps"
#                   because "cp -p" was causing permissions errors.
# Tue Sep 15, 2020: I'm creating a radically-different version of this program, called
#                   "process-spotlight-new.pl", using a subfolder of /d/sl called "Aggregator"
#                   which permanently aggregates all spotlight photos from rhe source
#                   directories, and uses the File::Type and Image::Size CPAN modules to only
#                   copy those files from the sources which are wide jpg files with names
#                   which are not yet in Aggregator to Aggregator, then only copy those files
#                   in Aggregator which are not already in /d/sl to /d/sl .
# Wed Sep 16, 2020: Aggregator now uses jpg files.
# Thu Sep 17, 2020: Fixed bug in which copy_wide_jpgs was trying to copy nonexistent files.
# Tue Oct 27, 2020: Dramatically simplified.
# Fri Oct 30, 2020: Fixed bug that was skipping all Windows SL files, and simplified what's printed.
# Tue Nov 06, 2020: Made an Aragorn-only version of "process-spotlight.pl".
# Mon Nov 09, 2020: Cleaned-up some var names, comments, and formatting.
# Fri Nov 13, 2020: Now converting file names to SHA1 hash. Changed shebang to remove utf8 input.
# Thu Nov 19, 2020: Now also presenting short version of new_name.
# Fri Nov 20, 2020: Fixed "$flag not getting reset" bug, which had been resulting in no files being copied
#                   after detection of first duplicate.
# Fri Dec 18, 2020: Changed "copy_wide_jpgs" to copy to/from arbitrary source and destination.
#                   Moved "copy_wide_jpgs" to RH::Dir. Changed name of "verify_directory" to
#                   "directory_exists" and moved it to RH::Dir.
# Thu Dec 31, 2020: Now using sub "copy_large_images_sha1" to copy images from /usl# to /d/sl.
# Thu Dec 31, 2020: Dramatically simplified, by using "/usl#" SYMLINKDs in "/".
# Fri Mar 12, 2021: Discontinued use of "Administrator".
# Sun Sep 26, 2021: Reinstituted use of "Administrator". Removed "Recent".
# Sat Nov 20, 2021: Refreshed shebang, colophon, titlecard, and boilerplate.
#                   Now using "common::sense" and "Sys::Binmode".
# Thu Nov 25, 2021: Simplified subroutine names.
# Tue Dec 14, 2021: Now using "current user" instead of "Aragorn" for single-user photo aggregating.
# Fri Sep 01, 2023: Reduced width from 120 to 110. Upgraded from "v5.32" to "v5.36". Got rid of CPAN module
#                   "common::sense" (antiquated). Got rid of all prototypes.
# Sat Sep 02, 2023: Improved help and argv.
# Fri Apr 25, 2025: Now using "utf8::all". Simplified shebang to "#!/usr/bin/env perl". Nixed "e".
##############################################################################################################

# Pragmas:
use v5.36;
use strict;
use warnings;

# CPAN Modules:
use utf8::all;
use Time::HiRes 'time';

# RH Modules:
use RH::Dir;

# ============================================================================================================
# SUBROUTINE PRE-DECLARATIONS:

sub argv; # Process @ARGV.
sub help; # Provide user with help.

# ============================================================================================================
# VARIABLES:

my $Debug   = 0;
my $Current = 0;

# ============================================================================================================
# MAIN BODY OF SCRIPT:

{ # begin main
   # Set time and program variables:
   my $t0 = time;
   my $pname = substr $0,1+rindex $0,'/';

   # Process @ARGV:
   argv;

   # Announce program entry:
   say "Now entering program \"process-spotlight.pl\".";

   # Announce mode:
   $Current and say "Mode = \"Process Current User Only\"."
            or  say "Mode = \"Process All Users\".";

   # Define a hash of user/directory key/value pairs. Each '/usl#' is a symbolic link in '/' to the actual
   # locations of the Windows Spotlight directories for each user. ("USL" = "User Spotlight Locations".)
   # These are my users. For your system, substitute-in your actual users.
   my %USLs = (
                 'Aragorn'       => '/usl1',
                 'Administrator' => '/usl2',
                 'Urgabor'       => '/usl3',
                 'Zebulon'       => '/usl4',
              );

   # If debugging, print all user/directory key/value pairs:
   if ($Debug) {
      for ( sort keys %USLs ) {
         say "key = \"$_\"; value = \"$USLs{$_}\".";
      }
   }

   # Determine whether or not all needed directories exist:
   my $cusr  = getlogin     ; # Current user.
   my $cusl  = $USLs{$cusr} ; # Current user's spotlight location.
   my $valid = 0            ; # Do all needed directories exist?
   if ( $Current ) {
      $valid =
         -e $cusl   && -d $cusl
      && -e '/d/sl' && -d '/d/sl';
   }
   else {
      $valid =
         -e '/usl1' && -d '/usl1'
      && -e '/usl2' && -d '/usl2'
      && -e '/usl3' && -d '/usl3'
      && -e '/usl4' && -d '/usl4'
      && -e '/d/sl' && -d '/d/sl';
   }

   # If all needed directories exist, print verification message;
   # otherwise, print error message and exit:
   if ( $valid ) {
      say 'Verified that all needed directories exist.';
   }
   else {
      say 'Fatal error in program \"process-spotlight.pl\":';
      say 'Some of the needed directories don\'t exist!';
      say 'Aborting program to prevent disaster!';
      exit 666;
   }

   # Update directory /d/sl from user directories:
   foreach my $user ( sort keys %USLs ) {
      next if $Current && $user ne $cusr;
      say '';
      say "User = \"$user\".";
      copy_files($USLs{$user}, '/d/sl', 'large', 'unique', 'sha1', 'sl', 'corr');
   }

   # Print exit message, including elapsed time, and exit:
   say '';
   say "Now exiting \"$pname\".";
   printf "Execution time was %.3f seconds.\n", time-$t0;
   exit 0;
} # end main

# ============================================================================================================
# SUBROUTINE DEFINITIONS:

sub argv {
   my $s = '[a-zA-Z0-9]';
   for ( @ARGV ) {
      /^-$s*h/ || /^--help$/    and help and exit;
      /^-$s*e/ || /^--debug$/   and $Debug = 1;
      /^-$s*c/ || /^--current$/ and $Current = 1;
   }
} # end sub argv

# Provide help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   Welcome to "process-spotlight.pl", Robbie Hatley's nifty Windows 10
   "Spotlight" scenic photo aggregator.

   Command lines:
   process-spotlight.pl [-h | --help]    (print this help and exit)
   process-spotlight.pl [options]        (process spotlight photos)

   Options:
   -h or --help       Print this help and exit.
   -e or --debug      Print diagnostic information.
   -c or --current    Process spotlight photos for current user only.
   Multiple single-letter options may be piled after a single hyphen;
   for example, use "-ce" to process current user only and debug.

   To use this program:

   1. Install Microsoft Windows 10 on a computer, and set the computer to use
      "Windows Spotlight" for its "Lock" and "Log-in" screens. That will pull-in
      scenic photos.

   2. Install Cygwin on your computer, including the Perl that comes with it.
      That will give you the Linux-like file-access syntax this script needs.
      (Oh, and, you'll need to become expert at using Windows, Cygwin, and Perl
      before anything in this script will make sense to you. So do that.)

   3. You'll also need my "RH" modules; you can get them here:
      https://github.com/robbie-hatley/CLI-Programming/tree/main/modules/RH

   4. Give yourself permission to access the Windows Spotlight folders for
      all of your user ids. Those are located here:
      C:\Users\YourUserId\AppData\Local\Packages\
         Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets
      By default they're not accessible, so you'll have to manually seize control
      by following this procedure:
      1. In Windows Explorer, go into C:\Users\YourUserID\AppData\Local\Packages\
      2. Right-click "Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy"
         and select "properties".
      2. Click "Security" tab.
      3. Click "Advanced".
      4. Seize ownership, and apply to all children.
      5. Click "OK" to close out of all boxes.
      6. Go back into advanced security settings, give yourself full control, and
         apply to all children.
      7. CLick "OK" to close out of all boxes again.
      8. Do steps 1-7 above for each of your user names.
      You should now have full control of those folders.

   5. Create symbolic links called 'usl1', 'usl2', etc, in Cygwin's root directory
      ('/') to your user spotlight folders (see step 4 above for where those are
      and how to gain access to them). Edit this script as necessary to account
      for the actual users on your system for which you want to aggregate
      Spotlight photos.

   6. Create a symbolic link called 'd' in '/' to the storage device where you
      want to store your Windows10 Spotlight photos. For example:
      cd /
      ln -s '/cygdrive/c' d

   7. Create a symbolic link called 'sl' in 'd' to the directory where you
      want to store your Windows10 Spotlight photos. For example:
      cd /d
      ln -s '/cygdrive/c/Spotlight' sl

   8. Make this script executable, rename it to whatever you like, and create
      an "alias" for it in your ~/.bashrc file (I use "psl").

   9. Run this script daily by typing it's file name or alias. It will then
      accumulate many beautiful huge hi-res full-color scenic photographs in
      whatever folder you set "sl" to point to.

   Happy scenic photo collecting!

   Cheers,
   Robbie Hatley,
   Programmer

   END_OF_HELP
   return 1;
}
