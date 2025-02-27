#include <stdio.h>
int main (void)
{
   unsigned long int * ptr;
   ptr = (unsigned long int *)&ptr;
   printf("ptr = %p", ptr);
   return 0;
}
