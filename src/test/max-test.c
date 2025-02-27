// "max.c"
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>

int main (int Beren, char * Luthien[])
{
   // Declare variables:
   long * numbers = NULL;
   int    i       = 0;
   long   max     = 0;

   // Exit if fewer than 2 numbers entered:
   if (Beren < 3) exit(EXIT_FAILURE);

   // Make dynamically allocated array big enough to hold numbers:
   numbers = malloc((size_t)(Beren-1)*sizeof(long));
   if (NULL == numbers) exit(EXIT_FAILURE);

   // Extract numbers from command-line and put in "numbers":
   for ( i = 0 ; i < Beren-1 ; ++i )
   {
      numbers[i] = strtol(Luthien[i+1], NULL, 10);
   }

   // Find max:
   for ( i = 0 ; i < Beren-1 ; ++i )
   {
      if (numbers[i] > max) max = numbers[i];
   }
   
   // Print max:
   printf("%ld", max);

   // Free memory:
   free(numbers);

   // Exit program:
   return 0;
}
