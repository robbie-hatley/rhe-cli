// shift-2-test.cpp
#include <iostream>
#include <iomanip>
int main(void)
{
   unsigned int Blat = 0x80000000;
   Blat = Blat >> 21;
   std::cout << "Shifted value in hex: " << std::hex << Blat << std::endl;
   std::cout << "Shifted value in dec: " << std::dec << Blat << std::endl;
   return 0;
}


