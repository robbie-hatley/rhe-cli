#!/usr/bin/env -S perl -C63

# This is a 110-character-wide Unicode UTF-8 Perl-source-code text file with hard Unix line breaks ("\x0A").
# ¡Hablo Español! Говорю Русский. Björt skjöldur. ॐ नमो भगवते वासुदेवाय.    看的星星，知道你是爱。 麦藁雪、富士川町、山梨県。
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# gcdk.pl
# Calculates the great-circle distance, in kilometers, between any two locations on Earth, given their
# geographic coordinates in either decimal degrees (default) or deg-min-sec.
# Written by Robbie Hatley.
# Edit history:
# Wed Mar 05, 2025: Wrote it.
# Thu Mar 20, 2025: Added deg-min-sec mode. Shortened name to "gcdk.pl".
##############################################################################################################

use v5.00;
use utf8;
use strict;
use warnings;

use Scalar::Util qw( looks_like_number        );
use Math::Trig   qw( pi great_circle_distance );

# ======= VARIABLES: =========================================================================================

# Settings:     Default:      Meaning of setting:       Range:    Meaning of default:
my @Opts      = ()        ; # options                   array     Options.
my @Args      = ()        ; # arguments                 array     Arguments.
my $Debug     = 0         ; # Debug?                    bool      Don't debug.
my $Help      = 0         ; # Just print help and exit? bool      Don't print-help-and-exit.
my $Dms       = 0         ; # Enter deg-min-sec mode?   bool      Don't use deg-min-sec.
my $Lat1      = 0         ; # Latitude  of location 1   num       0N0E
my $Lon1      = 0         ; # Longitude of location 1   num       0N0E
my $Lat2      = 0         ; # Latitude  of location 2   num       0N0E
my $Lon2      = 0         ; # Longitude of location 2   num       0N0E

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub help    ; # Print help and exit.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Process @ARGV:
   argv;
   # NOTE: argv calls either "deg" or "dms" depending on whether user specified degrees-minutes-seconds mode
   # (by using a "-d" or "--dms" flag) or not. By the time we get here, $Lat1, $Lon1, $Lat2, $Lon2 are set
   # to the correct values in radians for the user's inputs.

   # Convert geographic coordinates (in radians) to spherical coordinates (in radians):
   my $θ1 =        $Lon1; # Angle around equator       of location 1.
   my $ϕ1 = pi/2 - $Lat1; # Angle down from north pole of location 1.
   my $θ2 =        $Lon2; # Angle around equator       of location 2.
   my $ϕ2 = pi/2 - $Lat2; # Angle down from north pole of location 2.
   my $r  =         6365; # Radius of Earth in km, skewed towards poles a bit. (Polar is 6358, Equator 6378.)

   # Calculate great-circle distance in km:
   my $gcd = great_circle_distance($θ1, $ϕ1, $θ2, $ϕ2, $r);
   # NOTE: great_circle_distance() uses spherical coordinates (θ,ϕ), NOT geographical coordinates (Lat, Long).

   # Print result:
   printf "Great Circle Distance = %.3fkm\n", $gcd;

   # Exit program, returning success code "0" to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV :
sub argv {
   # Get options and arguments:
   my $end = 0;              # end-of-options flag
   my $s = '[a-zA-Z0-9]';    # single-hyphen allowable chars (English letters, numbers)
   my $d = '[a-zA-Z0-9=.-]'; # double-hyphen allowable chars (English letters, numbers, equal, dot, hyphen)
   for ( @ARGV ) {           # For each element of @ARGV,
      /^--$/                 # "--" = end-of-options marker = construe all further CL items as arguments,
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
      /^-$s*e/ || /^--debug$/   and $Debug   =  1  ;
      /^-$s*d/ || /^--dms$/     and $Dms     =  1  ;
   }

   if ($Debug) {print "\$Dms = $Dms\n";}

   # If we're in degrees-minutes-seconds mode, launch dms():
   if ($Dms) {dms();}

   # Otherwise we're in decimal-degrees mode so launch deg() instead:
   else {deg();}

   # Return success code 1 to caller:
   return 1;
} # end sub argv

# decimal-degrees mode:
sub deg {
   if ($Debug) {print "Just entered subroutine \"deg()\".\n";}

   # Get number of arguments:
   my $NA = scalar(@Args);

   # Die if number of arguments is not 4, or if arguments aren't numbers:
   if ( 4 != $NA || !looks_like_number($Args[0]) || !looks_like_number($Args[1])
                 || !looks_like_number($Args[2]) || !looks_like_number($Args[3]) ) {
      die "Error: Must have 4 numeric arguments: Lat1, Long1, Lat2, Long2.\n"
        . "Each argument should be in degrees, from -180 to +180.\n"
        . "Use negative numbers for W/S, positive numbers for E/N.\n"
        . "Use \"-h\" or \"--help\" for more help.\n";
   }

   # Convert latitude and longitude of the two locations from degrees to radians:
   $Lat1 = $Args[0] * pi / 180.0; # Latitude  of first  location.
   $Lon1 = $Args[1] * pi / 180.0; # Longitude of first  location.
   $Lat2 = $Args[2] * pi / 180.0; # Latitude  of second location.
   $Lon2 = $Args[3] * pi / 180.0; # Longitude of second location.

   if ($Debug) {
      print "At bottom of subroutine \"deg()\".\n";
      print "Lat1 = $Lat1\n";
      print "Lon1 = $Lon1\n";
      print "Lat2 = $Lat2\n";
      print "Lon2 = $Lon2\n";
   }

   # We succeeded, so return success code 1 to caller:
   return 1;
}

# degress-minutes-seconds mode:
sub dms {
   if ($Debug) {print "Just entered subroutine \"dms()\".\n";}

   # Get number of arguments:
   my $NA = scalar(@Args);

   # Die if number of arguments is not 16, or if arguments are wrong types:
   if (     16 != $NA
         || !looks_like_number($Args[ 0])
         || !looks_like_number($Args[ 1])
         || !looks_like_number($Args[ 2])
         || $Args[ 3] !~ m/^[ns]$/i
         || !looks_like_number($Args[ 4])
         || !looks_like_number($Args[ 5])
         || !looks_like_number($Args[ 6])
         || $Args[ 7] !~ m/^[ew]$/i
         || !looks_like_number($Args[ 8])
         || !looks_like_number($Args[ 9])
         || !looks_like_number($Args[10])
         || $Args[11] !~ m/^[ns]$/i
         || !looks_like_number($Args[12])
         || !looks_like_number($Args[13])
         || !looks_like_number($Args[14])
         || $Args[15] !~ m/^[ew]$/i       ) {
      die "Error: Must have 16 arguments:\n"
        . "Lat1deg, Lat1min, Lat1sec, S or N,\n"
        . "Lon1deg, Lon1min, Lon1sec, W or E,\n"
        . "Lat2deg, Lat2min, Lat2sec, S or N,\n"
        . "Lon2deg, Lon2min, Lon2sec, W or E\n"
        . "Each numeric argument should be in degrees from 0 to +180.\n"
        . "Don't use negative numbers in DMS mode! Instead, use S or N\n"
        . "for arguments 4 and 12, and W or E for arguments 8 and 16.\n"
        . "Use \"-h\" or \"--help\" for more help.\n";
   }

   # Convert latitude and longitude of the two locations from dms(dir) to radians:
   $Lat1 = ($Args[ 0]+$Args[ 1]/60+$Args[ 2]/3600) * pi / 180.0; # Latitude of first location.
   if ($Args[ 3] =~ m/s/i) {$Lat1 *= (-1)}                       # If south, make it negative.
   $Lon1 = ($Args[ 4]+$Args[ 5]/60+$Args[ 6]/3600) * pi / 180.0; # Longitude of first  location.
   if ($Args[ 7] =~ m/w/i) {$Lon1 *= (-1)}                       # If west, make it negative.
   $Lat2 = ($Args[ 8]+$Args[ 9]/60+$Args[10]/3600) * pi / 180.0; # Latitude  of second location.
   if ($Args[11] =~ m/s/i) {$Lat2 *= (-1)}                       # If south, make it negative.
   $Lon2 = ($Args[12]+$Args[13]/60+$Args[14]/3600) * pi / 180.0; # Longitude of second location.
   if ($Args[15] =~ m/w/i) {$Lon2 *= (-1)}                       # If west, make it negative.

   if ($Debug) {
      print "At bottom of subroutine \"dms()\".\n";
      print "Lat1 = $Lat1\n";
      print "Lon1 = $Lon1\n";
      print "Lat2 = $Lat2\n";
      print "Lon2 = $Lon2\n";
   }

   # We succeeded, so return success code 1 to caller:
   return 1;
}

# Print help:
sub help {
   print ((<<'   END_OF_HELP') =~ s/^   //gmr);

   -------------------------------------------------------------------------------
   Introduction:

   Welcome to "great-circle-distance-km.pl". Given the geographic coordinates of
   two locations on Earth, this program prints the great-circle distance between
   them in kilometers.

   -------------------------------------------------------------------------------
   Command lines:

   gcdk.pl -h | --help           (to print this help and exit)
   gcdk.pl lat1 lon1 lat2 lon2   (to print great-circle distance in dec-deg mode)
   gcdk.pl --dms (16 args)       (to print great-circle distance in dms mode)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print help and exit.
   -e or --debug      Print diagnostic info.
   -d or --dms        Use degrees-minutes-seconds mode.

   All other options are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments (Decimal Degrees Mode):

   In the default "decimal degrees mode", this program takes exactly 4
   command-line arguments:

   lat1 = latitude  of first  location in degrees
   lon1 = longitude of first  location in degrees
   lat2 = latitude  of second location in degrees
   lon2 = longitude of second location in degrees

   Each argument should be in the range -180 to +180.
   Use negative numbers for West longitude or South latitude.
   Use positive numbers for East longitude or North latitude.

   For example, to measure the distance from Hotel Alexandria in Los Angeles
   to Eiffel Tower in Paris, first find their locations:
   Hotel Alexandria = 34°02'51"N 118°15'00"W, so lat1=34.0475, lon1=-118.2500
   Eiffel Tower     = 48°51'30"N   2°17'40"E, so lat2=48.8583, lon2=   2.2944
   Plugging those 4 numbers into this program gives:
   %gcdk.pl 34.0475 -118.2500 48.8583 2.2944
   Great Circle Distance = 9074.536km

   -------------------------------------------------------------------------------
   Description of Arguments (Degrees-Minutes-Seconds Mode):

   If you use a "--dms" option, you will enter "degrees-minutes-seconds" mode.
   In this mode, this program takes exactly 16 command-line arguments:

   lat1_deg = degrees   part of latitude  of first  location (0 to 180)
   lat1_min = minutes   part of latitude  of first  location (0 to  60)
   lat1_sec = degrees   part of latitude  of first  location (0 to  60)
   lat1_dir = direction part of latitude  of first  location ( S or N )
   lon1_deg = degrees   part of longitude of first  location (0 to 180)
   lon1_min = minutes   part of longitude of first  location (0 to  60)
   lon1_sec = seconds   part of longitude of first  location (0 to  60)
   lon1_dir = direction part of longitude of first  location ( W or E )
   lat2_deg = degrees   part of latitude  of second location (0 to 180)
   lat2_min = minutes   part of latitude  of second location (0 to  60)
   lat2_sec = seconds   part of latitude  of second location (0 to  60)
   lat2_dir = direction part of latitude  of second location ( S or N )
   lon2_deg = degrees   part of longitude of second location (0 to 180)
   lon2_min = minutes   part of longitude of second location (0 to  60)
   lon2_sec = seconds   part of longitude of second location (0 to  60)
   lon2_dir = direction part of longitude of second location ( W or E )

   Each "degree" argument should be in the range 0 to 180.
   Each "minute" argument should be in the range 0 to  60.
   Each "second" argument should be in the range 0 to  60.
   Each "direction" argument should be S or N for latitude, W or E for longitude.

   Don't use negative numbers in degrees-minutes-seconds mode!
   Instead, use S, N, W, E to indicate direction.

   For example, to measure the distance from Hotel Alexandria in Los Angeles
   to Eiffel Tower in Paris, first find their locations:
   Hotel Alexandria = 34°02’51”N 118°15’00”W
   Eiffel Tower     = 48°51’30”N   2°17’40”E
   Plugging those 16 arguments into this program gives:
   %gcdk.pl --dms 34 2 51 N 118 15 00 W 48 51 30 N 2 17 40 E
   Great Circle Distance = 9074.536km

   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
