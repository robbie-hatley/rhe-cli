/* sizeof-test.c */

#include <stdio.h>

int main (void)
{
   void  *gargoyle = 0;
   
   gargoyle = malloc(147);
   printf("gargoyle = malloc(147);");
   printf("sizeof( gargoyle) = %ld\n", sizeof( gargoyle));
   printf("sizeof(*gargoyle) = %ld\n", sizeof(*gargoyle));
   free(gargoyle);
   return 0;
}
