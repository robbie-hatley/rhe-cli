// is-equal-test.c
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
int main (int Beren, char ** Luthien)
{
   if (4 != Beren)
      return 1;
   float p, d, m;
   bool is_equal;
   p = strtof(Luthien[1], NULL);
   d = strtof(Luthien[2], NULL);
   m = strtof(Luthien[3], NULL);
   is_equal = (fabs(40*m - 15*d - p) < 0.000001);
   if (is_equal)
      printf("Equation \"p=40m-15d\" is true.");
   else
      printf("Equation \"p=40m-15d\" is false.");
   return 0;
}
