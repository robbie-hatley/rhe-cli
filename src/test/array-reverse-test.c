#include <stdio.h>
int main (void)
{
   // Set size to 5:
   #define n 5

   // Create original array and load with 5 elements:
   int Fred [n] = {37, 2946, -985, 127, -3};

   // Make an index variable to riffle through arrays:
   int i = 0;

   // Print original array:
   printf("Original array:\n");
   for ( i = 0 ; i <= n-1 ; ++i )
   {
      printf("%d ", Fred[i]);
   }
   printf("\n\n");

   // Create a new array of size n, uninitialized:
   int Elen [n];

   // Loop through original array from end to beginning,
   // copying element i to element [(n-1)-i]:
   for ( i = n-1 ; i >= 0 ; --i )
   {
      Elen[(n-1)-i] = Fred[i];
   }

   // Print new array:
   printf("Reversed array:\n");
   for ( i = 0 ; i <= n-1 ; ++i )
   {
      printf("%d ", Elen[i]);
   }
   printf("\n");

   // We're done, so exit:
   return 0;
}
