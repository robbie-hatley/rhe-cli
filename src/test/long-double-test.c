
// long-double-test.c

#include <stdio.h>
#include <quadmath.h>

int main (void)
{
   float        var1 =              3.1415926535897932384626433832795F;
   double       var2 =              3.1415926535897932384626433832795;
   long double  var3 =              3.1415926535897932384626433832795L;
   __float128   var4 = strtoflt128("3.1415926535897932384626433832795", NULL);
   char str4[100];
   quadmath_snprintf(str4, 100, "%79.75Qf", var4);
   printf("%lu\n", sizeof(float));
   printf("%lu\n", sizeof(double));
   printf("%lu\n", sizeof(long double));
   printf("%79.75f\n",   var1);
   printf("%79.75f\n",   var2);
   printf("%79.75Lf\n",  var3);
   printf("%s\n",        str4);
   return 0;
}
