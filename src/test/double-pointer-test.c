#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#define ROWS 20
#define COLS 30

int main (void)
{
   size_t i = 0;
   size_t j = 0;
   double ** pp = NULL;
   
   // Allocate a block of row-head pointers for fake "2D array":
   pp = malloc(ROWS*sizeof(double*));
   
   // Allocate rows for fake "2D array":
   for ( i = 0 ; i < ROWS ; ++i )
   {
      pp[i] = malloc(COLS*sizeof(double));
   }

   // Seed the random number generator:
   srand((unsigned)time(NULL));

   // For each row:
   for ( i = 0 ; i < ROWS ; ++i )
   {
      // For each column:
      for ( j = 0 ; j < COLS ; ++j )
      {
         pp[i][j] = -5000.0 + 10000.0 * ((double)rand() / (double)RAND_MAX);
      }
   }
   
   // For each row:
   for ( i = 0 ; i < ROWS ; ++i )
   {
      // For each column:
      for ( j = 0 ; j < COLS ; ++j )
      {
         printf("%f  ", pp[i][j]);
      }
   }

   // Free the contents of each row:
   for ( i = 0 ; i < ROWS ; ++i )
   {
      free(pp[i]);
   }

   // Free the row-head-pointers block:
   free(pp);

   // Exit:
   return 0;
}
