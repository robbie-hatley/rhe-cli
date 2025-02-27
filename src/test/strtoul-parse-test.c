/* strtoul-parse-test.c */
#include <stdio.h>
#include <stdlib.h>

int main (void)
{
   unsigned long   Fred           = 0;
   char            Bob [42]       = "0xx";
   char          * Remainder      = NULL;

   Fred = strtoul(Bob, &Remainder, 16);
   printf("Fred = %lu\n", Fred);
   printf("Remainder = %s\n", Remainder);
   return 0;
}
