// substitute-characters-in-string-test.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main (void)
{
   char MyString    [128] = "n+1";
   char MyInsertion [128] = "32.9875";
   char MyCombined  [128] = "";

   // First, copy the "32.9875"
   // to MyCombined:
   strcpy(MyCombined, MyInsertion);

   // Then concatenate the "+1" from MyString
   // to the end of MyCombined:
   strcat(MyCombined, &MyString[1]);

   // Finally, print result:
   printf("%s\n", MyCombined);
   return 0;
}