/* expression-test.c */
#include <stdio.h>
int main (void)
{
   double x, y;
   double a = 3.726;
   double b = 1.759;
   double c = -5.208;
   for ( x = -5.0 ; x < 5.01 ; x += 0.1 )
   {
      y = a * x * x + b * x + c; /* EXPRESSION */
      printf("f(%4.1f) = %7.3f\n", x, y);
   }
   return 0;
}