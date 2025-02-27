/* division-test.c */

#include <stdio.h>

int main (void)
{
   double n = 1.000013;
   double m = 1.001867;
   int    i;
   for ( i = 0 ; i < 5 ; i = i + (int)n )
   {
      while ( n < 8.0)
      {
         n *= m;
         printf("i=%d n=%f\n", i, n);
      }
      while ( n > 2.0)
      {
         n /= m;
         printf("i=%d n=%f\n", i, n);
      }
   }
   return 0;
}
