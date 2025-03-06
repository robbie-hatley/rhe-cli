#!/usr/bin/env perl

# This is a 110-character-wide ASCII Perl-source-code text file with hard Unix line breaks ("\x0A").
# =======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

##############################################################################################################
# great-circle-distance-km.pl
# Calculates the great-circle distance between two locations on Earth, given their geographic coordinates,
# L
# Written by Robbie Hatley.
# Edit history:
# Sat Jun 05, 2021: Wrote it.
##############################################################################################################

use Scalar::Util qw( looks_like_number        );
use Math::Trig   qw( pi great_circle_distance );

# ======= SUBROUTINE PRE-DECLARATIONS: =======================================================================

sub argv    ; # Process @ARGV.
sub help    ; # Print help and exit.

# ======= LEXICAL VARIABLES: =================================================================================

my $lat1 = 0.0 ; # Latitude  of first  location.
my $lon1 = 0.0 ; # Longitude of first  location.
my $lat2 = 0.0 ; # Latitude  of second location.
my $lon2 = 0.0 ; # Longitude of second location.
my $dist = 0.0 ; # Distance in kilometers between first and second locations.

# ======= MAIN BODY OF PROGRAM: ==============================================================================

{ # begin main
   # Process @ARGV:
   argv;

   # Print distance in km:
   print
   "Distance = ",
   great_circle_distance($lon1, pi/2-$lat1, $lon2, pi/2-$lat2, 6371.0),
   "km\n";

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
   $lat1 = $ARGV[0] * pi / 180.0;
   $lon1 = $ARGV[1] * pi / 180.0;
   $lat2 = $ARGV[2] * pi / 180.0;
   $lon2 = $ARGV[3] * pi / 180.0;

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
