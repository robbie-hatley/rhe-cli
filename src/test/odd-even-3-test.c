// odd-even-3.c
#include <stdio.h>
#include <stdlib.h>
int main (int Beren, char *Luthien[])
{
   long  number  = 0;
   long  x       = 0;
	int   flash   = 0;

   // Exit if Beren isn't 2. This ensures that 
   // the number of command-line arguments is 1.
   if (2 != Beren)
      exit(EXIT_FAILURE);

   // Get number from command-line argument into number,
   // and copy into x as well:
   x = number = strtol(Luthien[1], NULL, 10);

   // Force x to be positive:
   if (x < 0)
      x = -x;

   // Ride a painted pony,
   // let the spinning wheel spin:
   while (x--) // Loop while decrementing x.
      flash = !flash; // Flash flash between 0 and 1.

   // If flash is now non-zero, number is odd:
   if (flash)
      printf("%ld is odd\n", number);

   // Otherwise, flash is 0 and number is even:
   else
      printf("%ld is even\n", number);

   // We're done, so exit:
   exit(EXIT_SUCCESS);
}
