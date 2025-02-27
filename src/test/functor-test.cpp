#include <iostream>

struct SayHi 
{
   void operator() (void)
   {
      std::cout << "Hello, World!" << std::endl;
   }
};

int main (void)
{
   SayHi Greeter;
   Greeter();
   return 0;
}
   