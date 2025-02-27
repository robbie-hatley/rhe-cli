// char-array-getline-test.c
#include <stdlib.h>
#include <stdio.h>

int main (void)
{
   char   * Buffer = NULL; // array of characters
   size_t   Count  = 0;    // count of characters

   printf("Type a line of text.\n");
   getline(&Buffer, &Count, stdin);
   printf("You typed:\n");
   printf("%s\n", Buffer);
   return 0;
}
