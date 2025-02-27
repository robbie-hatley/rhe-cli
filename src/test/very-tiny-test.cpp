#include <cstdlib>
#include <cstring>
#include <cctype>
#include <cmath>
#include <ctime>
#include <iostream>
#include "rhutil.hpp"
#include "rhdir.hpp"

namespace blat
{
   using std::cout;
   using std::endl;
}

int main()
{
   using namespace blat;
   double a = 0.15;
   double b = 4.5;
   const double TINY = 1.0e-10;
   
   cout << "b    = " << b    << endl;
   cout << "a    = " << a    << endl;
   cout << "b/a  = " << b/a  << endl;
   cout << "TINY = " << TINY << endl;
   
   if (fmod(b, a) > TINY)
      cout << "TRUE" << endl;
   else
      cout << "FALSE" << endl;
   
   return 0;
}
