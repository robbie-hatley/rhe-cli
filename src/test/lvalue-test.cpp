#include <iostream>
#include <cstring>
using std::cout;
using std::endl;
int main()
{
   char Text[128] = "fjwux";
   cout << "Original string = " << Text << endl;
   short Add = (static_cast<short>('a')); // 0x0061, little-endian 0x6100
   strcat(Text, reinterpret_cast<char*>(&Add)); // concatenates "a/0"
   cout << "Add = " << std::hex << std::showbase << Add << endl;
   cout << "Combined string = " << Text << endl;
   return 0;
}

