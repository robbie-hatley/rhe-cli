#include <stdio.h>
#include <stdlib.h>
int main(void)
{
   int a[5] = {1,2,3,4,5};
   for ( int i = 0 ; i < 5 ; ++i ) {
      int x = a[i]; // NOT an alias!
      x*=2; // Does NOT alter input!
      printf("%d\n",x);
   }
   for ( int i = 0 ; i < 5 ; ++i ) {
      printf("%d\n",a[i]);
   }
   return 0;
}
