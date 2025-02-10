#include <stdio.h>
#include <stdlib.h>
int main (int Beren, char **Luthien){
   if (2 != Beren) {return 666;}
   double cm, in;
   cm = strtod(Luthien[1],NULL);
   in = cm/2.54;
   printf("%f\n",in);
}
