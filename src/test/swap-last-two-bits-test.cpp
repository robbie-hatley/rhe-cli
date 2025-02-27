// swap-last-two-bits-test.cpp
#include <iostream>
int main (int Robin, char * Marian[])
{
   unsigned n = 0;
   unsigned m = static_cast<unsigned>(-4);
   unsigned r = 0;
   if (Robin > 1)
   {
      n = static_cast<unsigned int>
          (
             strtoul(Marian[1], NULL, 10)
          );
      r = (n&m)+((n&2)>>1)+((n&1)<<1);
      std::cout << r << std::endl;
   }
   return 0;
}