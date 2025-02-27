// weird-printf-test.c
#include <stdio.h>
int main (void)
{
   int x = 3;
   x = 7 && printf ("The number is: " + x * 2);
   return 0;
}
