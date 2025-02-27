#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <errno.h>
#include <error.h>

int main (int Beren, char * Luthien[])
{
   long x = 0;             // number
   long b = 0;             // backwards number
   int  L = 0;             // log10 of number
   int  i = 0;             // iterator
   int  digits [16] = {0}; // [16] is for 64-bit CPU. 
                           // Reduce to [8] for 32-bit CPU.
   int  counter = 0;       // digit counter
   long place = 0;         // place value

   if (Beren != 2) 
   {
      error(EXIT_FAILURE, EINVAL, "Needs 1 argument.");
   }

   x = strtol(Luthien[1], NULL, 10);
   L = (int)floor(log10((double)x)); // power of big-end digit
   
   for ( i = L ; i >= 0 ; --i )
   {
      place = (long)pow(10.0,(double)i);
      counter = 0;
      while (x >= place)
      {
         x -= place;
         ++counter;
      }
      digits[i] = counter; // index = place value
   }

   for ( i = 0 ; i <= L ; ++i )
   {
      // Add each digit*PlaceValue to b, but in reverse order:
      b += digits[i]*(long)pow(10.0,(double)(L-i));
   }
   printf("%ld\n", b);   
   return 0;
}
