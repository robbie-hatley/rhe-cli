
// square-fun-test.c

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <namegen.h>

double square (double x) {
   return x*x;
}

void print_random_name (void) {
   char *rname;
   srand((unsigned)time(0));
   rname=getrandomname();
   printf("%s\n", rname);
   free(rname);
   return;
}
