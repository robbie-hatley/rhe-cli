// simple-primes-test.c
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main (void)
{
   int Count;
   int Candidate;
   int Divisor;
   int Limit;
	int Composite;

   printf("%d\n", 2);
   printf("%d\n", 3);
   Count = 2;

   Candidate = 5;
   while (Count < 100)
   {
      Limit = (int)floor(sqrt(Candidate));
      Composite = 0;
      for ( Divisor = 3 ; Divisor <= Limit ; Divisor += 2 )
      {
         if (Candidate % Divisor == 0)
         {
            Composite = 1;
            break;
         }
      }
      if (!Composite)
      {
         printf("%d\n", Candidate);
         ++Count;
      }
      Candidate += 2;
   }

   return 0;
}