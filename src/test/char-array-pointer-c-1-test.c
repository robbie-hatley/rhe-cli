/* char-array-test.c */
#include <stdio.h>
char Func(char* blat) 
{
   return *(blat+1);
}
int main(void)
{
   char a[80];
   a[0] = 'n';
   a[1] = 't';
   printf("Func(&a) = %c\n", Func(&a));
   return 88;
}

