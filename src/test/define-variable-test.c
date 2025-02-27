#include <stdio.h>

// declare, define, and allocate Fred:
int Fred;

void Selena (void)
{
   // declare, define, and allocate Susan:
   int Susan;
   // assign a value to Susan:
   Susan = 92;
   printf("%d  %d\n", Fred, Susan);
}

int main (void)
{
   // assign a value to Fred:
   Fred = 47;
   Selena();
   return 0;
}