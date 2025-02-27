// reinterpret-test.c
#include <stdio.h>
int main (void)
{
   long x = 5125402636085405804L;
   double * p = (double*)&x;
   printf("%.15le\n",*p);
   *p=9.85;
   printf("%.15le\n",*p);
   return 0;
}
