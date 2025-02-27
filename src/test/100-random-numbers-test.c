// 100-random-numbers.c

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

int main (void)
{
   int i;

   // Seed the random number generator:
   srand((unsigned)time(NULL));

   // Print 100 random positive integers:
   for ( i = 0 ; i < 100 ; ++i )
   {
      printf("%d\n", rand());
   }

   return 0;
}
