#include <iostream>
#include <fstream>
int main(int, char* Sam[])
{
   std::ifstream Bob;
   Bob.open(Sam[1]);
   std::string buffer;
   while (42)
   {
      getline(Bob, buffer);
      if (Bob.fail()) std::cerr << "Stream failed!" << std::endl;
      if (Bob.eof())
      {
         std::cout << "eof" << std::endl;
         break;
      }
      std::cout << buffer << std::endl;
   }
   return 0;
}
