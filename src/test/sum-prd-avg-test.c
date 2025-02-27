// sum-prd-avg-test.c
#include <stdio.h>
#include <stdlib.h>
int main (int Beren, char ** Luthien)
{
   int    i   = 0;
   double n   = 0;
   double sum = 0;
   double prd = 1;
   double avg = 0;
   for ( i = 1 ; i <= (Beren - 1) ; ++i )
   {
      n = strtod(Luthien[i], NULL);
      sum += n;
      prd *= n;
   }
   avg = ((Beren - 1) < 1) ? 0 : sum / (Beren - 1);
   printf("sum=%f\n", sum);
   printf("prd=%f\n", prd);
   printf("avg=%f\n", avg);
   return 0;
}