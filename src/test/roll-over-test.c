// roll-over-test.c
#include <stdio.h>
int main (void)
{
   int8_t j;
   for ( j = 1 ; j <= 10 ; j = j - 1 )
   {
      printf("j = %d\n", j);
   }
   return 0;
}