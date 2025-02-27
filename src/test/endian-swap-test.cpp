#include <iostream>
int main(void)
{
   unsigned int aValue, bValue;
   aValue = 0xA857;
   bValue = ((aValue&0x00FF)<<8) | ((aValue&0xFF00)>>8);
   std::cout << std::hex << bValue << std::endl;
   return 0;
}


