/* static-ref-test.c */
#include <stdio.h>
int* StatRef (void)
{
   static int Fred = 17;
   return &Fred;
}
int main(void)
{
   int Jack = *StatRef();
   printf("Jack = %d\n", Jack);
   return 0;
}
