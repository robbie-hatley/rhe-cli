#include <stdio.h>
#include <stdlib.h>
int main (int Beren, char **Luthien){
   if (2 != Beren) {return 666;}
   double mm, in;
   in = strtod(Luthien[1],NULL);
   mm = in*25.4;
   printf("%f\n",mm);
}
