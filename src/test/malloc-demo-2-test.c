/* malloc-demo-2.c */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

int main (void)
{
   const size_t   BufSiz  = 10000000;
   size_t         i       = 0;
   int          * BufPtr  = NULL;

   // Allocate space for 10 million ints:
   BufPtr = (int*)malloc(BufSiz*sizeof(int));

   // Load 10 million ints into buffer:
   for ( i = 0 ; i < BufSiz ; ++i )
   {
      BufPtr[i] = rand();
   }

   // Print buffer contents:
   for ( i = 0 ; i < BufSiz ; ++i )
   {
      printf("%d\n", BufPtr[i]);
   }

   // Free the buffer:
   free(BufPtr);

   // We're done, so exit:
   return 0;
}
