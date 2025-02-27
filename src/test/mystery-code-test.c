#include <stdio.h>
int main (void)
{
   int i;
   int j;
   int x = 0; 
   for ( i = 0 ; i < 5 ; ++i )
   {
      for ( j = 0 ; j < i ; ++j ) 
      {
         x += (i + j - 1); 
         printf ("%d ", x);
      }
      printf ("\n");
   }
   printf ("x = %d\n", x);
   return 0;
}