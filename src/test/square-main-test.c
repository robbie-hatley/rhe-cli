
// square-main-test.c

#include <stdio.h>
#include <stdlib.h>

extern double square            (double x) ; // defined in square-fun-test.c
extern void   print_random_name (void)     ; // defined in square-fun-test.c

int main (int argc, char *argv[]) {
   double x; // number to be squared
   double y; // square of x
   if ( 2 != argc ) {
      return 1; // Error: number of args isn't 1
   }
   x = strtod(argv[1], NULL);
   y = square(x);
   printf("%f squared = %f\n", x, y);
   print_random_name();
   return 0;
}
