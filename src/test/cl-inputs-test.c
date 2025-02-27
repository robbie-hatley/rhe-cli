// cl-inputs-test.c
#include <stdio.h>
#include <stdlib.h>
int main (int Beren, char * Luthien[])
{
   int      i;
   double * Fred;
   if (Beren < 2) {return 0;}
   Fred = (double*)malloc((size_t)Beren*sizeof(double));
   for ( i = 1 ; i <  Beren ; ++i )
   {
      Fred[i] = strtod(Luthien[i], NULL);
   }
   printf("You typed %d numbers.\n", Beren);
   printf("The numbers you entered were:\n");
   for ( i = 1 ; i <  Beren ; ++i )
   {
      printf("%f\n", Fred[i]);
   }
   return 0;
}