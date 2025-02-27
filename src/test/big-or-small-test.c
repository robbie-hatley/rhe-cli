// big-or-small-test.c

#include <stdio.h>
#include <stdlib.h>

int main (void)
{
   // Variables:
   char   * buffer  = NULL; // Pointer to 0th byte of buffer.
   size_t   n       = 0;    // Number of bytes stored in buffer.
   int      result  = 0;    // Did sscanf work?
   int      weight  = 0;    // Weight in avoirdupois pounds.

   // Request user weight:
   printf("Enter your naked body weight in pounds: ");

   // Store input from stdin to a buffer,
   // store address of buffer in "buffer",
   // and store number of bytes stored in "n":
   getline(&buffer, &n, stdin);

   // Scan buffer; if buffer contains the ASCII representation
   // of an integer, store that integer in "weight" and set
   // "result" to 1; otherwise, set "result" to 0:
   result = sscanf(buffer, "%d", &weight);

   // Release the dynamically-allocated buffer created by
   // getline:
   free(buffer);

   // If we failed to get weight, exit:
   if (1 != result)
   {
      fprintf
      (
         stderr,
         "Error: invalid input.\n"
      );
      exit(EXIT_FAILURE);
   }

   // If person weighs < 125LB, they're small:
   if (weight < 125) {
      printf("Dude, you're small.\n");
   }

   // If person weighs < 175LB, they're average:
   else if (weight < 175) {
      printf("Dude, you're average.\n");
   }

   // If person weighs >= 175LB, they're big:
   else {
      printf("Dude, you're big.\n");
   }

   // Exit program:
   exit(EXIT_SUCCESS);
}
