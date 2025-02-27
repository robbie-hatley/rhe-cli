/* 0xx-test.c */

#include <stdio.h>
#include <stdlib.h>

int main (void)
{
   unsigned long Frank = 0;
   char * Remainder = NULL;

   Frank = strtoul("0xx", &Remainder, 16);
   printf("Frank = %lu\n", Frank);
   printf("Remainder = %s\n", Remainder);
   return 0;
}

