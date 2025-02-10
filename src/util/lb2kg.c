#include <stdio.h>
#include <stdlib.h>
int main (int Beren, char **Luthien){
   if (2 != Beren) {return 666;}
   double lb, kg;
   lb = strtod(Luthien[1],NULL);
   kg = lb/2.20462;
   printf("%f\n",kg);
}
