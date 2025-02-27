/*
print-gpn.c
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include "rhdefines.h"
#include "rhutilc.h"

LL GPN (LL k)
{
   return k*(3*k-1)/2;
}

void PrintGPNs (void)
{
   LL i;
   for ( i = 1 ; i <= 10 ; ++i )
   {
      printf("%ld\n", GPN(+i));
      printf("%ld\n", GPN(-i));
   }
   return;
}

int main (void)
{
   PrintGPNs();
   return 0;
}
