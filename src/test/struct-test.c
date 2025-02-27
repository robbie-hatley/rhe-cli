#include <stdio.h>
struct TwoInts
{
   int IntVal1;
   int IntVal2;
};
int main (void)
{
   struct TwoInts Object;
   Object.IntVal1 = 17;
   Object.IntVal2 = 34;
   printf("%d", Object.IntVal1 * Object.IntVal2);
   return 0;
}
