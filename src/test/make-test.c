#include <stdio.h>
int main(void)
{
   double       A  =  1.0;
   float        B  =  -34.49F;
   long double  C  =  341E7L;
   printf("A = %g    B = %g    C = %Lg\n", A, B, C);
   return 0;
}
