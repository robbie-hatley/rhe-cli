#include <stdio.h>
int main (void)
{
   int i,j,k,m;
   for ( i = 1 ; i <= 4 ; ++i )
   {
      for ( j = 1 ; j <= 4 ; ++j )
      {
         for ( k = 1 ; k <= 4 ; ++k )
         {
            m = 100*i + 10*j + k;
            printf("%d\n", m);
         }
      }
   }
   return 0;
}
