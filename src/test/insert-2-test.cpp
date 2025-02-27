#include <fstream>
#include <iostream>

int main()
{
   std::fstream I;
   I.open("C:\\File.ext");
   if (I.is_open())
   {
      unsigned short a;
      I >> a;
      std::cout << "Number is: " << a << std::endl;
      I.close();
      return 0;
   }
   else
   {
      return 1;
   }
}
