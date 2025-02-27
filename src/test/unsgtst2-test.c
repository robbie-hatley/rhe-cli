#include <stdio.h>

const int march[31] = 
{
   8, 5, 7, 2, -4, -14,  -7, -4, -2,  0,
   0, 2, 5, 7,  2,  -4, -14, -7, -4, -2,
   1, 7, 2, 2, -2,  -3,  -4,  6, -4,  3, 9 
};

int main(void)
{
   unsigned  i          =  0;
   unsigned  count      = 31;
   int       sum        =  0;

   for( i = 0; i < count; i++ )
   {
      sum += march[ i ];
   }
   printf( "The average low temperature in March was"
           " %d degrees\n", sum / count );
   return 0;
}

