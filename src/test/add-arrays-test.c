// add-arrays-test.c

#include <stdio.h>
#include <stdlib.h>

void AddArrays(const double * a, const double * b, double * c, size_t n)
{
   size_t i;
   for ( i = 0 ; i < n ; ++i )
   {
      *c++ = *a++ + *b++;
   }
}

int main (void)
{
   size_t i;
   double bargle [5] = {3.9, 17.6, -99.2, 32.7, -1.6};
   double fargle [5] = {832.5, 737.8, 991.4, 886.7, 789.5};
   double gargle [5] = {0};

   AddArrays(bargle, fargle, gargle, 5);
   for ( i = 0 ; i < 5 ; ++i )
      printf("%6.1f ", gargle[i]);
   return 0;
}
