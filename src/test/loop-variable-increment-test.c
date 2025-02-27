/* loop-variable-increment-test.c */
#include <stdio.h>
int main(void)
{
   int i = 0;
   for ( i = 1 ; i <= 10 ; ++i )
   {
      auto int MyVar = 0;
      ++MyVar;
      printf("MyVar = %d\n", MyVar);
   }
   printf("\n");
   for ( i = 1 ; i <= 10 ; ++i )
   {
      static int MyVar = 0;
      ++MyVar;
      printf("MyVar = %d\n", MyVar);
   }
   return 0;
}
