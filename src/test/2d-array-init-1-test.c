#include <stdio.h>
int main (void)
{
   int i,j;
   int Fred [17][34] = {{0}};
   for ( i = 0 ; i < 17 ; ++i )
   {
      for ( j = 0 ; j < 34 ; ++j )
      {
         printf("%d ", Fred[i][j]);
      }
      printf("\n");
   }
   return 0;
}
