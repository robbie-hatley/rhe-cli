#include <iostream>

namespace Romulan
{
   enum Ale : int
   {
      Brown  = 15,
      Amber  = 16,
      Lite   = 17
   };
}

int main()
{
   int           Input;
   Romulan::Ale  YourBeer;
   std::cout << "Enter beer code:" << std::endl;
   std::cin  >> Input;
   YourBeer = static_cast<Romulan::Ale>(Input);
   switch (YourBeer)
   {
      case Romulan::Brown:
         std::cout << "Yummy!" << std::endl;
         break;
      case Romulan::Amber:
         std::cout << "Pretty good." << std::endl;
         break;
      case Romulan::Lite:
         std::cout << "Eh." << std::endl;
         break;
      default:
         std::cout << "Your beer sux, dude!" << std::endl;
         break;
   }
   return 0;
}

