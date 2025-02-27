// first-non-repeated-test.c

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

int main (void)
{
   // Make some variables:
   char   * buffer  = NULL; // buffer pointer
   size_t   bufsiz  = 0;    // buffer size
   size_t   length  = 0;    // string length
   bool     result  = false;// allocation result
   size_t   i       = 0;    // outer index
   size_t   j       = 0;    // inner index
   bool     repeat  = false;// seen repeat yet?

   // Ask user to type a string:
   printf("Type a string and hit Enter:\n");

   // Store string in buffer:
   result = getline(&buffer, &bufsiz, stdin);

   // Exit if allocation failed:
   if (!result) exit(EXIT_FAILURE);

   // Get length of string:
   length = strlen(buffer);

   // Chomp newline by over-writing with '\0':
   buffer[length-1]='\0';
   length -= 1;

   // Announce string length:
   printf("String length = %ld\n", length);

   // Find non-repeats:
   for ( i = 0 ; i < length ; ++i )
   {
      repeat = 0;
      for ( j = 0 ; j < length ; ++j )
      {
         if (i == j) continue;
         if (buffer[i] == buffer[j])
         {
            repeat = 1;
            break;
         }
      }
      if (0 == repeat)
      {
         printf("First Non-Repeat: %c\n", buffer[i]);
         printf("At index: %ld", i);
         // We succeeded, so exit:
         exit(EXIT_SUCCESS);
      }
      // If we get to here, i & j are repeats,
      // so keep looping and try again.
   }
   // If we get to here, we failed, so exit:
   printf("No non-repeated characters were present.");
   exit(EXIT_FAILURE);
}
