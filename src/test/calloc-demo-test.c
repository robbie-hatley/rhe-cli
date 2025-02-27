// calloc-demo.c

#include <stdio.h>
#include <stdlib.h>

int main (void)
{
   const size_t   BufSiz  = 1000;
   size_t         i       = 0;
   int          * BufPtr  = NULL;

   // Allocate and clear space for 1000 ints:
   BufPtr = (int*)calloc(BufSiz, sizeof(unsigned));

   // Load 1000 ints into buffer:
   for ( i = 0 ; i < BufSiz ; ++i )
   {
      BufPtr[i] = rand() - 1000000000;
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
