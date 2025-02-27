/****************************************************************************\
 * test-bed.cpp
 * No telling what this program is about at any one time!  
 * It serves as a test bed to test programming ideas.  
 * Just paste-in your code below, and let 'r rip!
\****************************************************************************/

#include <iostream>
#include <list>
#include <string>

#include "rhutil.hpp"
#include "rhmath.hpp"
#include "rhdir.hpp"

long argle (32);

namespace ns_Test
{
   using std::cin;
   using std::cout;
   using std::cerr;
   using std::endl;
   
   struct Mess
   {
      double trouble;
      float  boat;
      unsigned long long int bob;
      long double tom;
      int greg;
   };
}

int main ()
{
   using namespace ns_Test;
   int bob = int(3 * argle);
   cout << bob << endl;
   // Insert your code here!!!!!!!
   float  a = 37.91374f;
   double b = 182789.91374;
   Mess   mess = {3856.39239, 477.1f, 385623456395, 384656.957314, 17};
   rhutil::PrintObjectBits(a,    cout); cout << endl;
   rhutil::PrintObjectBits(b,    cout); cout << endl;
   rhutil::PrintObjectBits(mess, cout); cout << endl;
   printf("static_cast<int>  (10.5F) = %i", static_cast<int>  (10.5F));

   return 0;
}
