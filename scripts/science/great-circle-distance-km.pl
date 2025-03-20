#!/usr/bin/env perl

# This is a 110-character-wide ASCII Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# great-circle-distance-km.pl
# Calculates the great-circle distance between two locations on Earth, given their geographic coordinates.
# Written by Robbie Hatley.
# Edit history:
# Wed Mar 05, 2025: Wrote it.
##############################################################################################################

use utf8;
use Scalar::Util qw( looks_like_number        );
use Math::Trig   qw( pi great_circle_distance );

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub help    ; # Print help and exit.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Process @ARGV:
   argv;

   # Get latitude and longitude of the two locations in radians:
   my $lat1 = $ARGV[0] * pi / 180.0; # Latitude  of first  location.
   my $lon1 = $ARGV[1] * pi / 180.0; # Longitude of first  location.
   my $lat2 = $ARGV[2] * pi / 180.0; # Latitude  of second location.
   my $lon2 = $ARGV[3] * pi / 180.0; # Longitude of second location.

   # Convert geographic coordinates (in radians) to spherical coordinates (in radians):
   my $θ1 =        $lon1; # Angle around equator       of location 1.
   my $ϕ1 = pi/2 - $lat1; # Angle down from north pole of location 1.
   my $θ2 =        $lon2; # Angle around equator       of location 2.
   my $ϕ2 = pi/2 - $lat2; # Angle down from north pole of location 2.
   my $r  =       6371.0; # Average radius of Earth in km.

   # Calculate great-circle distance in km:
   my $gcd = great_circle_distance($θ1, $ϕ1, $θ2, $ϕ2, $r);
   # NOTE: great_circle_distance() uses spherical coordinates (θ1, ϕ1,

   # Print result:
   print "Great Circle Distance = ${gcd}km\n";

   # Exit program, returning success code "0" to caller:
   exit 0;
} # end main

# ======= SUBROUTINE DEFINITIONS: ============================================================================

# Process @ARGV :
sub argv {
   # If user wants help, just print help and exit:
   for (@ARGV) {
      /^--help$/ and help and exit 0;
   }

   # Otherwise, we must have 4 numeric arguments:
   # lat1 lon1 lat2 lon2

   # Get number of arguments:
   my $NA = scalar(@ARGV);

   # Die if number of arguments is not 4, or if arguments aren't numbers:
   if (4 != $NA) {
      die "Error: Must have 4 arguments. Use \"--help\" to get help.\n";
   }
   if (!looks_like_number($ARGV[0])) {
      die "Error: Argument 1 non-numeric. Use \"--help\" to get help.\n";
   }
   if (!looks_like_number($ARGV[1])) {
      die "Error: Argument 2 non-numeric. Use \"--help\" to get help.\n";
   }
   if (!looks_like_number($ARGV[2])) {
      die "Error: Argument 3 non-numeric. Use \"--help\" to get help.\n";
   }
   if (!looks_like_number($ARGV[3])) {
      die "Error: Argument 4 non-numeric. Use \"--help\" to get help.\n";
   }

   # Return success code 1 to caller:
   return 1;
} # end sub argv

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

   program-name.pl -h | --help             (to print this help and exit)
   program-name.pl lat1 lon1 lat2 lon2     (to print great-circle distance)

   -------------------------------------------------------------------------------
   Description of Options:

   Option:            Meaning:
   -h or --help       Print help and exit.

   Any other options are ignored.

   -------------------------------------------------------------------------------
   Description of Arguments:

   This program takes exactly 4 command-line arguments:

   great-circle-distance-km.pl lat1 lon1 lat2 lon2

   lat1 = latitude  of first  location
   lon1 = longitude of first  location
   lat2 = latitude  of second location
   lon2 = longitude of second location


   Cheers,
   Robbie Hatley,
   programmer.
   END_OF_HELP
   return 1;
} # end sub help
__END__
