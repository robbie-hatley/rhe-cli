// leak-test.c

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef struct Numbers_tag
{
   size_t    count;
   double *  numbers;
} Numbers_t;

int main (void)
{
   // Declare variables:
   const size_t  Count = 50;
   size_t        i, j;
   double        Portion;
   double        RanNum;
   Numbers_t     Object;

   // Initialize Object:
   Object.count   = Count;
   Object.numbers = NULL;

   // Seed random number generator with time:
   srand((unsigned)time(NULL));

   // Create and display 5 clusters of 50 random
   // floating point numbers in range [-1000000, +1000000]:
   for ( i = 0 ; i < 5 ; ++i )
   {
      Object.numbers = malloc(Count*sizeof(double));
      for ( j = 0 ; j < Count ; ++j )
      {
         Portion = (double)rand() / (double)RAND_MAX;
         RanNum = -1000000.0 + 2000000.0 * Portion;
         Object.numbers[j] = RanNum;
      }
      for ( j = 0 ; j < Count ; ++j )
      {
         printf("%f  ", Object.numbers[j]);
      }
      printf("\n\n\n");
      // ***** PREVENT MEMORY LEAK BY CLEANING-UP!!! *****
      free(Object.numbers);
   }
   return 0;
}
