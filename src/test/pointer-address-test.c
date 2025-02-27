// pointer-address-test.c
#include <stdio.h>
int main (void)
{
   int* &a;
   printf("Value of a = %d\n", a);
   return 0;
}