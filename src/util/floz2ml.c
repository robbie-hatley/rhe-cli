#include <stdio.h>
#include <stdlib.h>
int main (int Beren, char **Luthien){
   if (2 != Beren) {return 666;}
   double floz, ml;
   floz = strtod(Luthien[1],NULL);
   ml = floz*29.5735295625;
   printf("%f\n",ml);
}
