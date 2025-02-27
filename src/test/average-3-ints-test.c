#include <stdio.h>
int main (void)
{
   char     * buffer  = NULL;
   size_t     n       = 0;
   int        ints[3] = {0};
   double     average = 0.0;

   printf("Enter three integers: ");
   getline(&buffer, &n, stdin);
   sscanf(buffer, "%d%d%d", &ints[0], &ints[1], &ints[2]);
   average = (ints[0] + ints[1] + ints[2]) / 3.0;
   printf("The average of %d and %d and %d is %f\n", 
      ints[0], ints[1], ints[2], average);
   return 0;
}
