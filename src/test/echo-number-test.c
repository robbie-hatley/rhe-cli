#include <stdio.h>
#include <stdlib.h>
int main (int Fred, char * Ethel[])
{
   if (Fred != 2) {return 666;}
   double Greg = strtod(Ethel[1],NULL);
   printf("%f\n", Greg);
   return 0;
}
