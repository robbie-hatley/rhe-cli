// This is a 120-character-wide ASCII C source-code text file.
//=======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

/**********************************************************************************************************************\
 * Program name:  Great Circle Distance, Degree-Minute-Second Variant
 * File name:     gcd_dms.c
 * Source for:    gcd_dms (Linux) or gcd_dms.exe (Windows).
 * Description:   Given the latitudes and longitudes of two sea-level points on the surface of Earth,
 *                given in degrees-minutes-seconds format, this program will calculate and print the
 *                distance between those two points in both kilometres and miles.
 * Inputs:        16 command-line arguments: 
 *                P1 latitude  degrees, minutes, seconds, direction;
 *                P1 longitude degrees, minutes, seconds, direction;
 *                P2 latitude  degrees, minutes, seconds, direction;
 *                P2 longitude degrees, minutes, seconds, direction.
 * Outputs:       Distance between P1 and P2 in kilometers and miles.
 * Note:          This program uses the "major axis = minor axis" variant of the Vincenty formula to avoid severe 
 *                rounding errors at short distances or antipodal points. This formula can be found at the bottom of 
 *                the "computational formulas" section of Wikipedia's "Great Circle Distance" article.
 * Author:        Robbie Hatley
 * Edit history:
 * Mon Jul 18, 2022: Wrote it.
 * Tue Jul 19, 2022: Corrected formatting errors, added comments, expanded "Note" above, etc.
\**********************************************************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <string.h>
#include <errno.h>
#include <error.h>

typedef struct Coords_tag
{
   double p1lat;
   double p1lon;
   double p2lat;
   double p2lon;
} Coords;

const double degrees_per_radian = 180.0 / M_PI;
const double radius_of_earth = 6371.0;

Coords process_args (int Beren, char * Luthien[])
{
   int     p1latd, p1lond, p2latd, p2lond; // Degrees
   int     p1latm, p1lonm, p2latm, p2lonm; // Minutes
   double  p1lats, p1lons, p2lats, p2lons; // Seconds
   char    p1latv, p1lonv, p2latv, p2lonv; // Vectors (S/N/W/E)
   Coords  coords;                         // Coordinates (in radians)
   int     i;

   // First make sure that we have exactly 16 arguments:
   if (17 != Beren) goto ERROR;

   // Next, make sure that every argument has a string length of at least 1:
   for ( i = 1 ; i <= 16 ; ++i )
   {
      if (strlen(Luthien[i])<1)
      {
         goto ERROR;
      }
   }

   // Now set all of the degrees, minutes, seconds, and vectors,
   // and check them for validity as we go:

   p1latd = (int)strtol(Luthien[ 1], NULL, 10);
   if (p1latd < 0 || p1latd > 90) goto ERROR;

   p1latm = (int)strtol(Luthien[ 2], NULL, 10);
   if (p1latm < 0 || p1latm > 60) goto ERROR;

   p1lats = strtod(Luthien[ 3], NULL);
   if (p1lats < 0.0 || p1lats > 60.0) goto ERROR;

   p1latv = Luthien[4][0];
   if ('S' == p1latv || 's' == p1latv)
   {
      p1latd = -p1latd;
      p1latm = -p1latm;
      p1lats = -p1lats;
   }
   else if ('N' == p1latv || 'n' != p1latv)
   {
      ; // Do nothing.
   }
   else
   {
      goto ERROR;
   }

   p1lond = (int)strtol(Luthien[ 5], NULL, 10);
   if (p1lond < 0 || p1lond > 180) goto ERROR;

   p1lonm = (int)strtol(Luthien[ 6], NULL, 10);
   if (p1lonm < 0 || p1lonm > 60) goto ERROR;

   p1lons = strtod(Luthien[ 7], NULL);
   if (p1lons < 0.0 || p1lons > 60.0) goto ERROR;

   p1lonv = Luthien[8][0];
   if ('W' == p1lonv || 'w' == p1lonv)
   {
      p1lond = -p1lond;
      p1lonm = -p1lonm;
      p1lons = -p1lons;
   }
   else if ('E' == p1lonv || 'e' != p1lonv)
   {
      ; // Do nothing.
   }
   else
   {
      goto ERROR;
   }

   p2latd = (int)strtol(Luthien[ 9], NULL, 10);
   if (p2latd < 0 || p2latd > 90) goto ERROR;

   p2latm = (int)strtol(Luthien[10], NULL, 10);
   if (p2latm < 0 || p2latm > 60) goto ERROR;

   p2lats = strtod(Luthien[11], NULL);
   if (p2lats < 0.0 || p2lats > 60.0) goto ERROR;

   p2latv = Luthien[12][0];
   if ('S' == p2latv || 's' == p2latv)
   {
      p2latd = -p2latd;
      p2latm = -p2latm;
      p2lats = -p2lats;
   }
   else if ('N' == p2latv || 'n' != p2latv)
   {
      ; // Do nothing.
   }
   else
   {
      goto ERROR;
   }

   p2lond = (int)strtol(Luthien[13], NULL, 10);
   if (p2lond < 0 || p2lond > 180) goto ERROR;

   p2lonm = (int)strtol(Luthien[14], NULL, 10);
   if (p2lonm < 0 || p2lonm > 60) goto ERROR;

   p2lons = strtod(Luthien[15], NULL);
   if (p2lons < 0.0 || p2lons > 60.0) goto ERROR;

   p2lonv = Luthien[16][0];
   if ('W' == p2lonv || 'w' == p2lonv)
   {
      p2lond = -p2lond;
      p2lonm = -p2lonm;
      p2lons = -p2lons;
   }
   else if ('E' == p2lonv || 'e' != p2lonv)
   {
      ; // Do nothing.
   }
   else
   {
      goto ERROR;
   }

   coords.p1lat = (p1latd + p1latm/60.0 + p1lats/3600.0)/degrees_per_radian;
   coords.p1lon = (p1lond + p1lonm/60.0 + p1lons/3600.0)/degrees_per_radian;
   coords.p2lat = (p2latd + p2latm/60.0 + p2lats/3600.0)/degrees_per_radian;
   coords.p2lon = (p2lond + p2lonm/60.0 + p2lons/3600.0)/degrees_per_radian;
   return coords;

ERROR:
   error
   (
      0,
      EINVAL,
      "Error: This program requires 16 space-separated command-line arguments which\n"
      "must be the latitude and longitude of two sea-level points on the surface of\n"
      "Earth in degrees, minutes, and seconds, in this order:\n\n"
      "Point 1 latitude  degrees\n"
      "Point 1 latitude  minutes\n"
      "Point 1 latitude  seconds\n"
      "Point 1 latitude  direction (W or E)\n\n"
      "Point 1 longitude degrees\n"
      "Point 1 longitude minutes\n"
      "Point 1 longitude seconds\n"
      "Point 1 longitude direction (S or N)\n\n"
      "Point 2 latitude  degrees\n"
      "Point 2 latitude  minutes\n"
      "Point 2 latitude  seconds\n"
      "Point 2 latitude  direction (W or E)\n\n"
      "Point 2 longitude degrees\n"
      "Point 2 longitude minutes\n"
      "Point 2 longitude seconds\n"
      "Point 2 longitude direction (S or N)\n\n"

      "Latitude    degrees must be in the interval [0, 180].\n"
      "Longitude   degrees must be in the interval [0, 90].\n"
      "Minutes and seconds must be in the interval [0, 60].\n"
      "Degrees and minutes should be integers, but seconds may be fractional.\n\n"

      "Don't use \"-\" signs on any of the arguments; instead, use S for south\n"
      "latitude and W for west longitude. For example:\n"
      "gcd_dms 51 29 14.103 N 0 5 9.497 E 33 55 13.006 N 117 22 37.102 W\n"
      "which will give distance from London, England to southern California.\n"
   );
   exit(EXIT_FAILURE);
}

double Vincenty (Coords coords)
{
   double phi1, phi2, lam1, lam2, dlam;
   double term1, term2, term3, term4;
   double numerator, denominator, dsig, d;
   phi1 = coords.p1lat;
   lam1 = coords.p1lon;
   phi2 = coords.p2lat;
   lam2 = coords.p2lon;
   dlam = lam2 - lam1;
   if (dlam < 0.0)  dlam = -dlam;
   if (dlam > M_PI) dlam = 2*M_PI - dlam;
   term1 = cos(phi2)*sin(dlam);
   term2 = cos(phi1)*sin(phi2) - sin(phi1)*cos(phi2)*cos(dlam);
   numerator = hypot(term1, term2);
   term3 = sin(phi1)*sin(phi2);
   term4 = cos(phi1)*cos(phi2)*cos(dlam);
   denominator = term3 + term4;
   dsig = atan2(numerator, denominator);
   d = radius_of_earth * dsig;
   return d;
}

int main(int Beren, char * Luthien[])
{
   Coords coords;
   double kilos, miles;
   coords = process_args(Beren, Luthien);
   kilos = Vincenty(coords);
   miles = 0.6213711922 * kilos;
   printf ("Distance = %.3f kilometers = %.3f miles.\n", kilos, miles);
   return 0;
}
