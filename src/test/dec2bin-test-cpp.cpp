// dec2bin-test-cpp.cpp
#include <iostream>
#include <iomanip>
using std::cout;
using std::endl; 
using std::setw;
int main (void)
{
   int i = 0;
   int x = 37;
   int bits[20]={0};
   for ( ; ; )
   {
      bits[i] = x%2;
      x = x/2;
      if (0 == x)
         break;
      ++i;
   }

   for ( ; i >= 0 ; --i ) cout << setw(1) << bits[i];

   return 0;
}
