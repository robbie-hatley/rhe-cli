// fib-rec-test.c
#include <stdio.h>
#include <stdlib.h>
uint64_t fib_rec (int index)
{
   if (0 == index) {return 1ul;}
   if (1 == index) {return 1ul;}
   return (fib_rec(index-1) + fib_rec(index-2));
}
int main (int Beren, char **Luthien)
{
   int n = 40;
   if (Beren > 1) {n = (int)strtoul(Luthien[1], NULL, 10);}
   for (int i = 0 ; i < n ; ++i)
   {
      printf("%lu ", fib_rec(i)); 
      fflush(stdout);
   }
   return 0;
}