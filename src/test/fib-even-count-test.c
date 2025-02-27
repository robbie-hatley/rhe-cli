#include <stdio.h>
int main (void)
{
   int a = 1; // first  number
   int b = 1; // second number
   int c = 2; // sum
   int d = 1; // even count
   while (c <= 1000000)
   {
      a = b;
      b = c;
      c = a+b;
      if (0 == c%2)
      {
         ++d;
      }
   }
   printf("%d\n", d);
}
