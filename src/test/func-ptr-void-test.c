
#include <stdio.h>

int (*blat)(void);

int asdf(void)
{
   return 5;
}

int main (void)
{
   blat = & asdf;
   printf("%d", (*blat)());
   return 0;
}
