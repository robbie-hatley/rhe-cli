#include <stdio.h>
#include <stdlib.h>
int main (int Beren, char **Luthien){
   if (2 != Beren) {return 666;}
   double ml, floz;
   ml = strtod(Luthien[1],NULL);
   floz = ml/29.5735295625;
   printf("%f\n",floz);
}
