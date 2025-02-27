// unnecessary-for-loops-test.c
#include <stdio.h>
int main (void)
{
   for ( int i = 0 ; i < 1 ; ++i )
   {
      for ( int j = 0 ; j < 1 ; ++j )
      {
         printf("54321 43215 32154 "
         	    "21543 15432\n");
      }
   }
   return 0;
}