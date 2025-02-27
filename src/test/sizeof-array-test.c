// sizeof-array-test.c
#include <stdio.h>
int main (void)
{
   int Sam [15];
   size_t Size = sizeof(Sam);
   printf("sizeof(Sam) = %ld\n",Size);   
   return 0;
}
