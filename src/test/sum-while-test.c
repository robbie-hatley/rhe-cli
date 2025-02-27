#include <stdio.h>
int main (void)
{
   int i   = -137;
   int sum = 13;
   while (i<=10)
   {
      sum += i; 
      i++;
   }
   printf("sum=%d\n", sum);
   return 0;
}