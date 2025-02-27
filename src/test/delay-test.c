// delay-test.c

#include <stdio.h>
#include <time.h>

// Make a (double) version of clock():
double dclock (void)
{
   return (double)clock()
         /(double)CLOCKS_PER_SEC;
}

// Delay n seconds:
void delay (double n)
{
   double t0 = dclock();
   double t1 = dclock();
   while ( t1 - t0 < n )
      t1 = dclock();
}

int main (void)
{
   printf("Loop with ten 0.25 second delays:\n");
   for ( int i = 0 ; i < 10 ; ++i )
   {
      printf("%d\n", i+1);
      delay(0.25);
   }
   return(0);
}
