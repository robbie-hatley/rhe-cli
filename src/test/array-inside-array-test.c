// array-inside-array-test.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main (void)
{
   int    A    [16]   = {39,  3, 20, 93, 15,
                          9, 52,  7, 33, 54, 
                         18,  6, 97, 31, 47, 0};
   
   int    B    [ 6]   = {73,  8, 54, 62,  3, 0};

   int *a = & A[5];
   int *b = & B[0];
   while ((*a++ = *b++)){}
   printf("%d %d %d %d %d %d\n", 
                  A[5], A[6], A[7], A[8], A[9], A[10]);
   return 0;
}
