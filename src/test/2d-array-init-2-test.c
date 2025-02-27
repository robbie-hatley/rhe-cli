#include <stdio.h>
#include <stdlib.h>
int main (void)
{
   double two_dim_array[5][10]; // = { { 0 } };
   int i,j;
   for ( i = 0 ; i < 5 ; ++i )
   {
      for ( j = 0 ; j < 10 ; ++j )
      {
         printf("%5.1f ", two_dim_array[i][j]);
      }
      printf("\n");
   }
   printf("\n");
   for ( i = 0 ; i < 5 ; ++i )
   {
      for ( j = 0 ; j < 10 ; ++j )
      {
         two_dim_array[i][j] = 10*i + j;
      }
   }
   for ( i = 0 ; i < 5 ; ++i )
   {
      for ( j = 0 ; j < 10 ; ++j )
      {
         printf("%5.1f ", two_dim_array[i][j]);
      }
      printf("\n");
   }
   printf("\n");
   printf("%p\n", &two_dim_array[3][9]);
   printf("%p\n", &two_dim_array[4][0]);
   exit(0);
}
