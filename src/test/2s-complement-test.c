// 2s-complement-test.c
#include <stdio.h>
int main (void)
{
   int a,b,c,d,e,f,g,h,x;
   x = 3;
   a = ( 128 & x) >> 7;
   b = (  64 & x) >> 6;
   c = (  32 & x) >> 5;
   d = (  16 & x) >> 4;
   e = (   8 & x) >> 3;
   f = (   4 & x) >> 2;
   g = (   2 & x) >> 1;
   h = (   1 & x);
   printf("%1d%1d%1d%1d%1d%1d%1d%1d",a,b,c,d,e,f,g,h);
}
