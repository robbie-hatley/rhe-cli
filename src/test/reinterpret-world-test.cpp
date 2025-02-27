// reinterpret-world.cpp
#include <iostream>
int main (void)
{
   unsigned Fred[3] = { 1819043144 , 1867980911 , 6581362 };
   std::cout << reinterpret_cast<char*>(Fred) << std::endl;
   return 0;
}
