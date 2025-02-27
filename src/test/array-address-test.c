#include <stdio.h>
int main (void)
{
   int A [5] = {8, 9385, -15208, 395, -984};
   printf("&A    = %lX\n", (unsigned long)&A   );
   printf("&A[0] = %lX\n", (unsigned long)&A[0]);
   printf("&A[1] = %lX\n", (unsigned long)&A[1]);
   printf("&A[2] = %lX\n", (unsigned long)&A[2]);
   printf("&A[3] = %lX\n", (unsigned long)&A[3]);
   printf("&A[4] = %lX\n", (unsigned long)&A[4]);
   return 0;
}
  