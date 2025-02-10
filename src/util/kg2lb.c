#include <stdio.h>
#include <stdlib.h>
int main (int Beren, char **Luthien){
   if (2 != Beren) {return 666;}
   double kg, lb;
   kg = strtod(Luthien[1],NULL);
   lb = kg*2.20462;
   printf("%f\n",lb);
}
