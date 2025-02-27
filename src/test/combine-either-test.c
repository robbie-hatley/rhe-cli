
// combine-either-test.c

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void print_binary (uint8_t x)
{
   for ( int i = 7 ; i >= 0 ; --i )
   {
      printf("%01d", (x >> i)%2);
   }
   return;
}


int main (int Beren, char * Luthien[])
{
   // Declare and define the variables we'll need:
   uint8_t mask1  = 0b00110100; // First  mask.
   uint8_t mask2  = 0b00001010; // Second mask.
   uint8_t mask3  = 0;          // Combo  mask.
   uint8_t number = 0;          // Number to be masked.
   uint8_t result = 0;          // Result.

   // Bail-out if number of CL args is not 1:
   if (2 != Beren) // (Beren will always be #-of-args + 1)
      exit(EXIT_FAILURE);

   // "Combine" (OR) the two masks together:
   mask3 = mask1 | mask2;

   // Get the number to be "masked":
   number = (uint8_t)strtol(Luthien[1], NULL, 10);

   // Get the result of "masking" (AND-ing) number with mask:
   result = number & mask3;

   // Print the results:

   printf("mask1  = ");
   print_binary(mask1);
   printf("\n");

   printf("mask2  = ");
   print_binary(mask2);
   printf("\n");

   printf("mask3  = ");
   print_binary(mask3);
   printf("\n");

   printf("number = ");
   print_binary(number);
   printf("\n");

   printf("result = ");
   print_binary(result);
   printf("\n");

   // We're done, so exit:
   exit(EXIT_SUCCESS);
}
