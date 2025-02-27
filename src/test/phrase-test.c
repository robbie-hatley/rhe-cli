#include <stdio.h>
#include <string.h>
#include <stdbool.h>
int main (void)
{
   size_t i, j, s;
   bool is_phrase;
   char input[3][50] = 
   {
      "Crudeness", 
      "Water under the bridge", 
      "Stride"
   };
   for  ( i = 0 ; i < 3 ; ++i )
   {
      s = strlen(input[i]);
      is_phrase = false;
      for ( j = 0 ; j < s ; ++j )
      {
         if (' ' == input[i][j])
         {
            is_phrase = true;
            break;
         }
      }
      if ( is_phrase )
      {
         printf("%s.\n", input[i]);
      }
   }
   return 0;
}
