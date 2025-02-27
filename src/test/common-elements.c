// common-elements.c
#include <stdio.h>
int main (void)
{
   char Array[3][10]=
   {
      "hydrogen", 
      "nitrogen",
      "oxygen"
   };
   int i;
   for ( i = 0 ; i < 3 ; ++i )
   {
      printf("%s\n", Array[i]);
   }
   return 0;
}