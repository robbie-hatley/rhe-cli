/* random-ratio-test.c */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>
#include <time.h>
int main (void)
{
   int      i;
   double   Min;
   double   Max;
   double   Ratio;
   Min = 2.0/7.0; // 0.2857
   Max = 7.0/2.0; // 3.5000
   printf("Min   = %f\n", Min);
   printf("Max   = %f\n", Max);
   srand((unsigned)time(NULL));
	for ( i = 0 ; i < 100 ; ++i )
	{
      Ratio = Min - 1.0 + exp(log(Max - (Min - 1.0))*((double)rand()/(double)RAND_MAX));
      // Note: This is the same as setting the Live:Total ratio between
      // 2:9 and 6:9 for each 9-cell neighborhood of 1 cell and its 
      // 8 neighbors (N, NE, E, SE, S, SW, W, NW).
      printf("Ratio = %f\n", Ratio);
	}
	return 0;
}