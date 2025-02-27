// powers-of-two-test-1.c
#include <stdio.h>
int *p2 (void);
int main (void) {
   for ( int i = 1 ; i <= 6 ; ++i ) {
      printf("%d\n", *p2());
   }
   return 0;
}
int *p2 (void) {
   static int p = 1; // Initialized to 1 first time only.
   p *= 2;           // Double the value of p.
   return &p;        // Return pointer to p.
}