// sum-pro-sos.c
#include <stdio.h>
#include <stdlib.h>
int main ( int Beren, char * Luthien[] )
{
   if (3 != Beren)
   {
      printf("Error. Please use two numerical arguments.\n");
      exit(EXIT_FAILURE);
   }
   double a = strtod(Luthien[1], NULL);
   double b = strtod(Luthien[2], NULL);
   printf("a = %f\n", a);
   printf("b = %f\n", b);
   printf("a+b = %f\n", a+b);
   printf("a*b = %f\n", a*b);
   printf("sum-of-squares = %f\n", a*a+b*b);
   exit(EXIT_SUCCESS);
}
