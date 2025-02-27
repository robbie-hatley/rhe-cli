#include <stdio.h>
int main (void)
{
   int Fred [5] = {37, 2946, -985, 127, -3}; // array
   size_t i = 0; // iterator (index)
   for ( i = 0 ; i < 5 ; ++i )
   {
      printf("%d\n", Fred[i]);
   }
   return 0;
}
