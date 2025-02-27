#include <stdio.h>
#include <stdlib.h>
int main (void) {
   int  i = 0;
   int *p = NULL;
   while (1) {
      ++i;
      p = (int*)malloc(1048576*sizeof(int)); // OMFG!!!
      printf("%p\n", p);
      if (i >= 100) {break;}
   }
   return 0;
}
