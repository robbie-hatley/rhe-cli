// This is a 120-character-wide ASCII C source-code text file.
//=======|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|=========|

/**********************************************************************************************************************\
 * Program name:  Great Circle Distance, Decimal Variant
 * File name:     gcd_dec.c
 * Source for:    gcd_dec (Linux) or gcd_dec.exe (Windows).
 * Description:   Given the latitudes and longitudes of two sea-level points on the surface of Earth,
 *                given in decimal-degrees format, this program will calculate and print the
 *                distance between those two points in both kilometres and miles.
 * Inputs:        4 command-line arguments: P1 latitude, P1 longitude, P2 latitude, P2 longitude.
 * Outputs:       Distance between P1 and P2 in miles and kilometers
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
   double  p1latd, p1lond, p2latd, p2lond; // Degrees
   Coords  coords;                         // Coordinates (in radians)
   int     i;

   // First make sure that we have exactly 4 arguments:
   if (5 != Beren) goto ERROR;

   // Next, make sure that every argument has a string length of at least 1:
   for ( i = 1 ; i <= 4 ; ++i )
   {
      if (strlen(Luthien[i])<1)
      {
         goto ERROR;
      }
   }

   // Now set the degrees, checking them for validity as we go:

   p1latd = strtod(Luthien[1], NULL);
   if (p1latd <  -90.0 || p1latd >  90.0) goto ERROR;

   p1lond = strtod(Luthien[2], NULL);
   if (p1lond < -180.0 || p1lond > 180.0) goto ERROR;

   p2latd = strtod(Luthien[3], NULL);
   if (p2latd <  -90.0 || p2latd >  90.0) goto ERROR;

   p2lond = strtod(Luthien[4], NULL);
   if (p2lond < -180.0 || p2lond > 180.0) goto ERROR;

   coords.p1lat = p1latd/degrees_per_radian;
   coords.p1lon = p1lond/degrees_per_radian;
   coords.p2lat = p2latd/degrees_per_radian;
   coords.p2lon = p2lond/degrees_per_radian;
   return coords;

ERROR:
   error
   (
      0,
      0,
      "Error: This program requires 4 space-separated command-line arguments which\n"
      "must be the latitude and longitude of two sea-level points on the surface of\n"
      "Earth in degrees, in this order:\n\n"

      "Point 1 latitude  degrees\n"
      "Point 1 longitude degrees\n"
      "Point 2 latitude  degrees\n"
      "Point 2 longitude degrees\n\n"

      "Latitude  degrees must be in the interval [-180, 180].\n"
      "Longitude degrees must be in the interval [ -90,  90].\n"
      "Degrees may either be integers, or may have fractional parts.\n"
      "Don't use W/E/N/S indicators; instead, use \"-\" to indicate\n"
      "south latitude or west longitude.\n\n"

      "Example:\n"
      "gcd_dec 51.406 0.119 33.937 -117.301\n"
      "That will give the distance from London, England to southern California.\n"
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
