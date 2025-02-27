// array-c-test.c
#include <stdio.h>
int main (void)
{
   char word[6] = "apple";     // 6 bytes
   int  numb[5]  = {3,8,5,7,6}; // 20 bytes (probably)
   printf("%s\n", word);
   printf("%d,%d,%d,%d,%d\n",
          numb[0],numb[1],numb[2],numb[3],numb[4]);
   printf("size of char array = %lu\n", sizeof(word));
   printf("size of int  array = %lu\n", sizeof(numb));
}
