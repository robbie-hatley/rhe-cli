// fib-rec-test.c
#include <stdio.h>
#include <stdlib.h>
int main (int Beren, char **Luthien)
{
   uint32_t   n    = 40;
   uint64_t * vals = NULL;
   if (Beren >  1) {n = (uint32_t)strtoul(Luthien[1], NULL, 10);}
   if (n < 3 || n > 92)
   {
      printf("Error: argument must be in the [3, 92] range.\n");
      exit(EXIT_FAILURE);
   }
   if (n > 92) {n = 92;}
   vals = malloc(n*sizeof(int64_t));
   vals[0] = 1;
   printf("%25lu\n", vals[0]);
   vals[1] = 1;
   printf("%25lu\n", vals[1]);
   for (uint32_t i = 2 ; i < n ; ++i)
   {
      vals[i] = vals[i-1] + vals[i-2];
      printf("%25lu\n", vals[i]); 
      fflush(stdout);
   }
   exit(EXIT_SUCCESS);
}