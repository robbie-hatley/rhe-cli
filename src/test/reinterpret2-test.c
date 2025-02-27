// reinterpret-test.c
#include <stdio.h>
int main (void)
{
   uint32_t Fred[3] = {17, 18753, 846}; 
   char * cp; 
   cp = (char*)&Fred[1];
   printf("%c\n", *cp);
   return 0;
}
