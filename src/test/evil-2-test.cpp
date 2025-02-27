// evil-test-2.cpp
#include <cstdio>
int main (void)
{
   int Fred[500];
   int i;
   for ( i = 0 ; i < 100000 ; ++i )
   {
      Fred[i] = i;
   }
   printf("Fred[34927] = %d\n", Fred[34927]);
   return 0;
}