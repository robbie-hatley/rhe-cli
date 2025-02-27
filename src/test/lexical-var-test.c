/* lexical-var-test.c */
#include <stdio.h>
int * array[12];
int main(int argc, char *argv[])
{
   int i = 0;
   for ( i = 1 ; i <= 10 ; ++i ) {
      int var = i;
      array[i] = &var;
      printf("Addr = %p  Value = %d\n", (void*)array[i], *array[i]);
   }
   return 0;
}
