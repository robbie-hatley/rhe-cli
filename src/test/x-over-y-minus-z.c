// x-over-y-minus-z.c
#include <stdlib.h>
#include <stdio.h>
int main (int Beren, char * Luthien[])
{
   double x = 0.0;
   double y = 0.0;
   double z = 0.0;
   double C = 0.0;
   if (4 != Beren)
   {
      fprintf(stderr, "Must have 3 arguments!\n");
      exit(EXIT_FAILURE);
   }
   x = strtod((*(Luthien+1)), NULL);
   y = strtod((*(Luthien+2)), NULL);
   z = strtod((*(Luthien+3)), NULL);
   C = x/y-z;
   printf("%f\n", C);
   exit(EXIT_SUCCESS);
}