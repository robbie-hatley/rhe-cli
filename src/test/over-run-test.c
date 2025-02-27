
// over-run-test.c

#include <stdio.h>

int main (void)
{
   int Fred[505] = {0};

   Fred[634] = 87592;
   printf("Fred[634] = %d\n", Fred[634]);
   return 0;
}