// average-no-array-test-c.c
#include<stdio.h>
int main (void)
{
   double Number      = 0.0;
   double Accumulator = 0.0;
   int    Count       = 0;
   printf("Enter some numbers, pressing Enter after each number,\n");
   printf("then enter 0 and press Enter to end data entry:\n");
   while (1)
   {
      scanf("%lf",&Number);
      if (Number < 0.000001) // floating-point is not exact!!!!!
         break;
      Accumulator += Number;
      ++Count;
   }
   if (0 != Count)
      printf("Average = %f\n", Accumulator/Count);
   return 0;
}
