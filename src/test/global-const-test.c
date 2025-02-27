// global-const-test.c
#include <stdio.h>
const double FEIGENBAUM = 4.669201609;
int main (void)
{
   double g = 37.2 - 9.5*FEIGENBAUM;
   printf("Enquantu eluva = %f\n", g - 1.5*FEIGENBAUM);
   return 0;
}