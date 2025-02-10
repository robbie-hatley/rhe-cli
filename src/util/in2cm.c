#include <stdio.h>
#include <stdlib.h>
int main (int Beren, char **Luthien){
   if (2 != Beren) {return 666;}
   double cm, in;
   in = strtod(Luthien[1],NULL);
   cm = in*2.54;
   printf("%f\n",cm);
}
