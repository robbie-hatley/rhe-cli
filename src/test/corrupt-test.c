#include <stdio.h>
#include <stdlib.h>
#include <time.h>
void corrupt (int *xp, size_t s)
{
   for ( size_t i = 0 ; i < s ; ++i )
   {
      xp[i] = (int)((double)rand()/(double)RAND_MAX*2.714*(double)xp[i]);
   }
   return;
}

int main (void)
{
   int ints [5] = {1,2,3,4,5};
   srand((unsigned)time(NULL));
   printf("Uncorrupted ints:\n");
   for ( size_t i = 0 ; i < 5 ; ++i )
   {
      printf("%d\n", ints[i]);
   }
   corrupt(ints,5);
   printf("\n\nCorrupted ints:\n");
   for ( size_t i = 0 ; i < 5 ; ++i )
   {
      printf("%d\n", ints[i]);
   }
   return 0;
}