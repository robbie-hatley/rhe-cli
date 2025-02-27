#include <stdio.h>
int main(void)
{
   int MyArray[30];
   int i;
   for ( i= 0 ; i < 37 ; ++i)
   {
      MyArray[i] = i;
      printf("element = %d\n", MyArray[i]);
   }
   return 0;
}
