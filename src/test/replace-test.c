// replace-test.c
#include <stdio.h>
int main (void)
{
   // Make a string:
   char String [55] = "This is a string.";

   // Replace string with a word:
			String[0] = 'd';
			String[1] = 'o';
			String[2] = 'g';
			String[3] = '\0';
   printf("%s\n", String);
   return 0;
}