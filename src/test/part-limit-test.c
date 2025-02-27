// part-limit-test.c
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
int main (void)
{
   int i;
   double LwrLim;
   double UprLim;
   for ( i = -20 ; i <= 20 ; ++i )
   {
      LwrLim = -(sqrt(24.0*(double)i+1.0)+1.0)/6.0;
      UprLim = +(sqrt(24.0*(double)i+1.0)-1.0)/6.0;
      printf("i = %d  LwrLim = %f  UprLim = %f\n", i, LwrLim, UprLim);
   }
   return 0;
}
