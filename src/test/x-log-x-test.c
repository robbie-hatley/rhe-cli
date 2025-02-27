// x-log-x-test.c
#include <stdio.h>
#include <math.h>
int main(void)
{
   double x;
   double z;
   for ( x = 1.0 ; x < 5.05 ; x += 0.1)
   {
      z = 2.0*x + x*log(x/2.0) - 2.0;
      printf("%f\n", z);
   }
   return 0;
}