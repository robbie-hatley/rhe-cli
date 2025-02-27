// element-test.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main (int Beren, char * Luthien[])
{
   size_t  Index;
   size_t  Length;
   char msg [256] = 
      "Four score and seven years ago, our fathers brought forth on "
      "this continent a new nation, conceived in Liberty, and dedicated "
      "to the proposition that all men are created equal.";

   if (Beren < 2)
   {
      fprintf
      (
         stderr, 
         "Error: requires 1 argument, which must be a positive integer "
         "giving the index of the character to be printed."
      );
      exit(EXIT_FAILURE);
   }

   Index = strtoul(Luthien[1], NULL, 10);
   Length = strlen(msg);
   if (Index >= Length)
   {
      fprintf
      (
         stderr, 
         "Error: index of character to be printed must be < %lu.\n",
         Length
      );
      exit(EXIT_FAILURE);
   }

   printf("%c\n", msg[Index]);
   return 0;
}
