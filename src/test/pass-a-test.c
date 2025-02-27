#include <stdio.h>
int main (void)
{
   char a = 'a';       // initialize a to 'a'
   char b = 'b';       // initialize b to 'b'
   b = a;              // pass value of a ('a') to b
   printf("%c\n", b);  // prints "a"
   return 0;
}
