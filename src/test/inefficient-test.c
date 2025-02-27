#include<stdio.h>

/* Find the "integer square root" of a number,
that is, the greatest integer not-greater-than
the actual square root of the number: */
int IntSqrt (int n)
{
   int i,j;
   double c,d,e,f,g,h;
   c = 1.0486729;
   d = 1.0136394;
   e = 1.0384656;
   f = 1.0837566;
   g = 1.0294753;
   h = 1.0374628;
   for ( j = 0 ; j < 1000000000 ; ++j )
   {
      c /= d;
      d /= e;
      e /= f;
      f /= g;
      g /= h;
      h /= c;
   }
   i = 1;
   while (i*i <= n)
   {
      ++i;
   }
   return i - 1 + (int)c;
}

int main(void)
{
   printf("integer square root of 10 = %d\n", IntSqrt(10));
   return 0;
}
