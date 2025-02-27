// case-insensitive-unique-test.c
#include <stdio.h> 
#include <string.h>
#include <ctype.h>
#include <stdbool.h>

// Make a function to determine if a C-style string
// contains only case-insensitively-unique characters:
bool is_case_insensitively_unique (char * s)
{
   size_t l = strlen(s);
   for ( size_t i = 0 ; i < l ; ++i )
   {
      for ( size_t j = 0 ; j < i ; ++j )
      {
         if ( tolower(s[j]) == tolower(s[i]) )
         {
            return false;
         }
      }
   }
   return true;
}

int main (void) 
{ 
   // First, make some strings:
   char strings [3][75] =
      {
         "She was a 747 captain.",
         "Paul pod!",
         "Two zebras?"
      };

   // Now, determine whether any of these strings
   // contain only case-insensitively-unique
   // characters:
   
   for ( size_t i = 0 ; i < 3 ; ++i )
   {
      if (is_case_insensitively_unique(strings[i]))
      {
         printf
         (
            "string \"%s\" contains only "
            "case-insensitively-unique "
            "characters.\n\n",
            strings[i]
         );
      }
      else
      {
         printf
         (
            "string \"%s\" does NOT contain only "
            "case-insensitively-unique "
            "characters.\n\n",
            strings[i]
         );
      }
   }
   return 0; 
}
