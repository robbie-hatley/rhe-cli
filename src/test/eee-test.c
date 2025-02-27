
// eee-test.c

#include <stdio.h>
#include <math.h>

int main (void)
{
   long double Base = 1.0L + powl(9.0L,-powl(4.0L,6.0L*7.0L));
   long double Expo = powl(3.0L,powl(2.0L,85.0L));
   long double Eeee = powl(Base,Expo);
   printf("Base = %Lf\n", Base);
   printf("Expo = %Lf\n", Expo);
   printf("Eeee = %Lf\n", Eeee);
   return 0;
}

/*

    a^(b^c) = ?
    a^(b+c) = (a^b)(a^c)
    a^(bc)  = a^(sum[b]c) = prod[b]a^c = (a^c)^b
    a^(bc)  = a^(sum[c]b) = prod[c]a^b = (a^b)^c

    3^(2^85) = 3^(2*2^84) = 9^(2^84) = 9^(2^(2*42)) = 9^((2^2)^42) = 9^(4^(6*7))


*/
