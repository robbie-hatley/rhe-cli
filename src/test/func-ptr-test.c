#include <stdlib.h>
#include <stdio.h>

double* Fred[3] = {NULL};

float WeirdFunc(double** Blat);

int main(void)
{
   float (*FunPtr1)(double**);
   Fred[0] = (double*)malloc(sizeof(double));
   Fred[1] = (double*)malloc(sizeof(double));
   Fred[2] = (double*)malloc(sizeof(double));
   *(Fred[0]) = 83.57;
   *(Fred[1]) = 57.83;
   *(Fred[2]) = 78.35;
   FunPtr1 = &WeirdFunc;
   printf("%f\n", (*FunPtr1)(&Fred[0]));
   printf("%f\n", (*FunPtr1)(&Fred[1]));
   printf("%f\n", (*FunPtr1)(&Fred[2]));
   free(Fred[0]);
   free(Fred[1]);
   free(Fred[2]);
   return 0;
}

float WeirdFunc(double** Blat)
{
   return (float)((**Blat)/3.45);
}

