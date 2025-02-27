#include <stdio.h>
#include <math.h>
int main(void)
{
   double x = 3.7;
   double z;
   z = 2.0*x + x*log(x/2.0) - 2.0;
   printf("%f\n", z);
   return 0;
}
