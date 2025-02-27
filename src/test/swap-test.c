
// swap-test.c

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <error.h>

// Read a bit (bit index is 0-63, right-to-left (63,62...1,0), so that
// each bit's index is also log2 of the place value of the bit):
// int ReadBit (uint64_t Int, int Idx)
  

// Set a bit:


// Error function:
void Error (void)
{
   error
   (
      EXIT_FAILURE, 
      0, 
      "Error: \"swap-test\" takes exactly 2 arguments,\n"
      "which must be integers in the range [-2147483648,+2147483647].\n"
   );
}

int main (int Beren, char * Luthien[])
{
   int64_t  a       = 0;     // first  number
   int64_t  b       = 0;     // second number

   // If number of arguments is wrong, print error msg and exit:
   if (3 != Beren)
   {
      Error();
   }

   // Get range:
   a = strtol(Luthien[1], NULL, 10);
   b = strtol(Luthien[2], NULL, 10);

   // If a or b is out-of-range, print error msg and exit:
   if (a < -2147483648 || a > 2147483647 || b < -2147483648 || b > 2147483647)
   {
      Error();
   }

   // Swap a and b:
   b *= 2147483648;

   // Print a and b:
   printf("%ld %ld\n", a, b);

   // We finished successfully, so exit, returning success code to OS:
   exit(EXIT_SUCCESS);
}