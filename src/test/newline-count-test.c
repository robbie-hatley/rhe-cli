// newline-count-test.c
#include <stdio.h>
int main (void)
{
   int  c   = 0;
   int  nl  = 0;
   while ((c=getchar()) != EOF)
      if ('\n' == c)
         ++nl;
   printf("%d\n", nl);
   return 0;
}