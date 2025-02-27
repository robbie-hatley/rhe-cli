// powers-of-two-test-2.c
#include <stdio.h>
#include <math.h>
int p2 (int *e);
int main (void) {
   for ( int e = 1 ; e <= 6 ; ++e ) {
      printf("%d\n", p2(&e));
   }
   return 0;
}
int p2 (int *e) {
   return (int)pow(2,*e);
}