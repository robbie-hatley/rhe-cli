// odd-even-1.c
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

   // If the remainder from dividing (double)x by 2.0
   // is < 0.1, x is even:
   if ( (double)x / 2.0 - (double)(x/2) < 0.1)
      printf("%ld is even\n", x);

   // Otherwise, x is odd:
   else
      printf("%ld is odd\n", x);

   // We're done, so exit:
   exit(EXIT_SUCCESS);
}
