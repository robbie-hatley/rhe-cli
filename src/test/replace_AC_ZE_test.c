// replace_AC_ZE_test.c
#include <stdio.h>
int main (void)
{
   char     * MyString  = NULL;
   size_t     MySize    = 0;
   size_t     i         = 0;
   printf("Type a string, then hit Enter.\n");
   getline(&MyString, &MySize, stdin);
   printf("Allocation size = %lu\n", MySize);
   printf("Original string:\n%s\n", MyString);
   for ( ; i < MySize ; ++i )
   {
      if ('A' == MyString[i])
      {
         MyString[i] = 'Z';
      }
      if ('C' == MyString[i])
      {
         MyString[i] = 'E';
      }
   }
   printf("\nAltered string:\n%s\n", MyString);
   return 0;
}