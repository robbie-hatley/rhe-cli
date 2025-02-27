/* malloc-demo.c */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

int main (void)
{
   int   i       = 0;
   int * BufPtr  = NULL;

   BufPtr = malloc(5*sizeof(int));
   if (NULL == BufPtr) {return 666;}
   BufPtr[0] = 39657378;
   BufPtr[1] = 94658385;
   BufPtr[2] = 59375629;
   BufPtr[3] = 91037845;
   BufPtr[4] = 24028563;
   
   for ( i = 0 ; i < 5 ; ++i )
   {
      printf("%d\n", BufPtr[i]);
   }

   free(BufPtr);

   return 0;
}
