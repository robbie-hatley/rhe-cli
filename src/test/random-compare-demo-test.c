/* random-compare-demo.c */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

int main (void)
{
   int i = 0;
   int m = 0;
   int n = 0;

   srand((unsigned)time(NULL));
   for ( i = 0 ; i < 10 ; ++i )
   {
      m = (int)floor(1000.0*(double)rand()/(double)RAND_MAX);
      n = (int)floor(1000.0*(double)rand()/(double)RAND_MAX);
      if (m  < n) printf("%d  < %d\n", m, n);
      if (m == n) printf("%d == %d\n", m, n);
      if (m  > n) printf("%d  > %d\n", m, n);
   }
   return 0;
}
