// inv-sqrt2.c
#include <stdio.h>
#include <stdlib.h>

float inv_sqrt (float x)
{
   int64_t i;
   float x2, y;
   const float threehalfs = 1.5F;
   x2 = x*0.5F;
   y  = x;
   i  = *(int64_t*)&y;
   i  = 0x5F3759DF-(i>>1);
   y  = *(float*)&i;
   y  = y*(threehalfs-x2*y*y);
   y  = y*(threehalfs-x2*y*y);
   return y;
}

int main (int Beren, char ** Luthien)
{
   float Input, Output;
   if (2 != Beren) {exit(1);}
   Input  = (float)strtod(Luthien[1], NULL);
   Output = inv_sqrt(Input);
   printf("1/sqrt(%f) = %f\n", Input, Output);
   return 0;
}