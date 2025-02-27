// const-para-test.c
#include <stdio.h>

double Gamma (const double x);

int main (void)
{
   printf("return value = %f\n", Gamma(3.8));
   return 0;
}

double Gamma (const double x)
{
   x = 1.018 * x; // ERROR; compilation will fail!
   return 2.37*x*x - 1.82*x + 0.402;
}
