// index-flip-test.c
#include <stdio.h>
int main (void) {
   int a[5] = {3,17,8,-6,22};
   printf("%d\n", a[3]);
   printf("%d\n", 3[a]);
   return 0;
}
