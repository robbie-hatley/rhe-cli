#include <iostream>
int& funct()
{
   static int p = 10;
   std::cout << p << std::endl;
   return p;
}

int main()
{
   int x = 17;
   funct() = x; // prints "10", then assigns 17 to "p" in "funct"
   funct();     // prints "17"
   return 0;
}
