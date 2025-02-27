// character-word-test.c
#include <stdio.h>
#include <stdlib.h>
int main (void) {
   // Declare an 8-bit variable to hold a character::
   char mychar = 'a';

   // Declare a 51-byte array of char, which can thus
   // hold up to a maximum of 50 characters, write the
   // word "word" to its first 4 elements, and fill
   // the remainder with '\0' NUL bytes (all bits zero):
   char mystring[50] = "word";

   // Print the character and the string we just created:
   printf("A character: %c\n", mychar);
   printf("A string   : %s\n", mystring);

   // We're done, so return success code to OS:
   return 0;
}
