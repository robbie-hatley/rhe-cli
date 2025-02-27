/*
gettimeofday-test.c
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>

/* Return high-resolution time as double (for timing things): */
double HiResTime (void)
{
   struct timeval t;
   gettimeofday(&t, NULL);
   return (double)t.tv_sec + (double)t.tv_usec / 1000000.0;
}

/* Program entry point: */
int main (void)
{
   printf("HiResTime = %f seconds.\n", HiResTime());
   return 0;
}
