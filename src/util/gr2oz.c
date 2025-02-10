#include <stdio.h>
#include <stdlib.h>
int main (int Beren, char **Luthien){
   if (2 != Beren) {return 666;}
   double gr, oz;
   gr = strtod(Luthien[1],NULL);
   oz = gr/28.3495;
   printf("%f\n",oz);
}
