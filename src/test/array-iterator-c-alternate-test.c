#include <stdio.h>
int main (void)
{
   int Fred [6] = {37, 2946, -985, 127, -3, 0}; // array
   int * p; // iterator (pointer)
   for ( p = &Fred[0]; (*p)!=0 ; ++p )
   {
      printf("%d\n", *p);
   }
   return 0;
}
