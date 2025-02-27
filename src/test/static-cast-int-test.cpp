#include <iostream>
int main (void)
{
   int x = static_cast<int>(7.8 + 15.5/2.0);
   std::cout << x << std::endl;
   return 0;
}