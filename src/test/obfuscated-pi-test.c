#include <stdio.h>
int a[52514],b,c=52514,d,e,f=10000,g,h;
int main (void)
{
   for ( ; (b=c-=14) ; h=printf("%04d", e+d/f) )
   {
      for ( e=d%=f ; (g=--b*2) ; d/=g )
      {
         d=d*b+f*(h?a[b]:f/5),a[b]=d%--g;
      }
   }
}