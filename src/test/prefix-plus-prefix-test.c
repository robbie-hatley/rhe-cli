// prefix-plus-prefix-test.c
#include <stdio.h>
int main (void)
{
   int n = 3;
   //n = ++n + ++n;
   int temp1 = ++n;
   int temp2 = ++n;
   n = temp1 + temp2;
   printf("%d\n", n);
   return 0;
}
