#include <stdio.h>
#include <stdlib.h>
int main (int Beren, char **Luthien){
   if (2 != Beren) {return 666;}
   double oz, gr;
   oz = strtod(Luthien[1],NULL);
   gr = oz*28.3495;
   printf("%f\n",gr);
}
