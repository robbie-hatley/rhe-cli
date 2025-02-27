// ascii-letter-case-test.c
#include <stdio.h>
#include <ctype.h>
int main (void)
{
   char c;
   printf("Type a letter and hit Enter.\n");
   c = (char)getchar();
   if (islower(c))
      printf("You typed a lower-case letter.\n");
   else
      printf("You did NOT type a lower-case letter.\n");
   return 0;
}