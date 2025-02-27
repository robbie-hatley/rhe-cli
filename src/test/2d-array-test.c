// 2d-array-test.c
#include <stdio.h>

int main (void)
{
   char MyArray[81] = {"Fred"};
   char My2DArray[20][81] = {"Sam", "Tom", "Bob"};
   printf("%s\n", MyArray);
   printf("%s\n", My2DArray[0]);
   printf("%s\n", My2DArray[1]);
   printf("%s\n", My2DArray[2]);
   return 0;
}
   