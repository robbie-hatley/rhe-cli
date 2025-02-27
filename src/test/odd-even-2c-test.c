// odd-even-2c-test.c (c ver of 2)
#include <stdio.h>
#include <stdlib.h>
int main (int Beren, char *Luthien[])
{
   long x = 0;

   // Exit if Beren isn't 2. This ensures that 
   // the number of command-line arguments is 1.
   if (2 != Beren)
      exit(EXIT_FAILURE);

   // Get x from command-line argument:
   x = strtol(Luthien[1], NULL, 10);

   // If (x modulo 2) is 0, x is even:
   if ( 0 == x % 2 )
      printf("%ld is even\n", x);

   // Otherwise, x is odd:
   else
      printf("%ld is odd\n", x );

   // We're done, so exit:
   exit(EXIT_SUCCESS);
}
