// print-float-or-int-test.c
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
int main (int Beren, char * Luthien[])
{
   double num = 0.0;

   if (2 != Beren)
   {
      fprintf(stderr, "Must have 1 argument!\n");
      exit(EXIT_FAILURE);
   }
   num = strtod(*(Luthien+1), NULL);
   if (fabs(num-(double)(int)num) > 0.0)
   {
      printf("%f\n", num);
   }
   else
   {
      printf("%d\n", (int)num);
   }
   exit(EXIT_SUCCESS);
}