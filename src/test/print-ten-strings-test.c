#include <stdio.h>
int main (void)
{
   int i;
   for ( i = 0 ; i <= 9 ; ++i )
   {
      printf("%d*%d*%d\n", i, i, i);
   }
   return 0;
}
