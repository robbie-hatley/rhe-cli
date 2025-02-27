/*
cat-speed-test.c
Compares speed of arithmetic and string versions
of my number-concatenating function "Cat".
Written Wed Feb 14, 2018 at 12:20PM by Robbie Hatley
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>

typedef unsigned long UL;

/* Primes under 100,000: */
#include "Array-Of-9592-Primes-Under-100000.cism"

UL Cats1[1000] = {0UL};
UL Cats2[1000] = {0UL};

/* Concatenate two numbers (arithmetic version): */
UL Cat1 (UL a, UL b)
{
   UL  mult  = 1UL;
   while (mult <= b) {mult *= 10UL;}
   return a*mult+b;
}

/* Concatenate two numbers (string version): */
UL Cat2 (UL a, UL b)
{
   char buffera [25] = {'\0'};
   char bufferb [25] = {'\0'};
   char bufferc [50] = {'\0'};
   sprintf(buffera, "%ld", a);
   sprintf(bufferb, "%ld", b);
   strcpy (bufferc, buffera);
   strcat (bufferc, bufferb);
   return strtoul(bufferc, NULL, 10);
}

double HiResTime (void)
{
   struct timeval t;
   gettimeofday(&t, NULL);
   return (double)t.tv_sec + (double)t.tv_usec / 1000000.0;
}

int main (void)
{
   double t1, t2, t3, t4;
   int    i;

   t1=HiResTime();
   for ( i = 0 ; i < 1000 ; ++i )
   {
      Cats1[i] = Cat1(Primes[2*i], Primes[2*i+1]);
   }
   printf("%ld  %ld  %ld\n", Cats1[0], Cats1[499], Cats1[999]);
   t2=HiResTime();
   printf("Arithmetic version elapsed time = %f seconds.\n", t2-t1);

   t3=HiResTime();
   for ( i = 0 ; i < 1000 ; ++i )
   {
      Cats2[i] = Cat2(Primes[2*i], Primes[2*i+1]);
   }
   printf("%ld  %ld  %ld\n", Cats2[0], Cats2[499], Cats2[999]);
   t4=HiResTime();
   printf("String version elapsed time = %f seconds.\n", t4-t3);

   return 0;
}
