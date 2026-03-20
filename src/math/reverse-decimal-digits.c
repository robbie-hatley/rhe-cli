/* reverse-decimal-digits.c */
#include <stdio.h>
#include <stdlib.h>

unsigned long ten_to_the (unsigned x) {
   unsigned long  y = 1;
   unsigned       i;
   for ( i = 1U ; i <= x ; ++i ) {
      y *= 10UL;
   }
   return y;
}

unsigned log_ten_of (unsigned long x)
{
   unsigned i;
   for ( i = 0U ; x >= 10UL ; ++i ) {
      x /= 10UL;
   }
   return i;
}

int main (int Beren, char *Luthien[]) {
   unsigned long  number;
   unsigned       digits;
   unsigned       i;
   if (2 != Beren) {
      exit(EXIT_FAILURE);
   }
   number = strtoul(Luthien[1], NULL, 10);
   digits = 1U + log_ten_of(number);
   for ( i = 0 ; i < digits ; ++i ) {
      printf("%lu", (number/ten_to_the(i))%10);
   }
   printf("\n");
   exit(EXIT_SUCCESS);
}
