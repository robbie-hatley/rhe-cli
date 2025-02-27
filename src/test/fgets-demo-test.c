#include <stdio.h>
int main (void)
{
   char buffer [50] = {'\0'};
   printf("Enter some text: ");
   fgets(buffer, 48, stdin);
   printf("String
   printf("You wrote: %s\n", buffer);
   return 0;
}
