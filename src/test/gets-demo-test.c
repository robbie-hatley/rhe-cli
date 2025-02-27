#include <stdio.h>
int main (void)
{
   char buffer [50] = {'\0'};
   printf("Enter some text: ");
   gets(buffer);
	printf("You wrote: %s\n", buffer);
	return 0;
}
