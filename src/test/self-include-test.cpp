#include <iostream>

using std::cout;
using std::endl;

namespace MyNameSpace 
{
   struct VERY_WEIRD
   {
      static VERY_WEIRD VW;
      int x;
   };
   VERY_WEIRD VERY_WEIRD::VW;
}

int main(void)
{
   using namespace MyNameSpace;
   VERY_WEIRD Puppy;
   Puppy.VW.x = 3;
   Puppy.x = 5;
   cout << "Puppy.VW.VW.VW.VW.VW.VW.VW.VW.VW.VW.VW.x = " 
        << Puppy.VW.VW.VW.VW.VW.VW.VW.VW.VW.VW.VW.x 
        << endl;
   cout << "Puppy.VW.VW.VW.VW.VW.VW.VW.VW.x = " 
        << Puppy.VW.VW.VW.VW.VW.VW.VW.VW.x 
        << endl;
   cout << "Puppy.VW.VW.VW.VW.VW.VW.VW.VW.VW.VW.VW.VW.VW.VW.x = " 
        << Puppy.VW.VW.VW.VW.VW.VW.VW.VW.VW.VW.VW.VW.VW.VW.x 
        << endl;
   cout << "Puppy.x = " 
        << Puppy.x 
        << endl;
   return 0;
}
