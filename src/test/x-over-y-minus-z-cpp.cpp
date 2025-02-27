// x-over-y-minus-z-cpp.cpp
#include <cstdlib>
#include <iostream>
using std::cout, std::cerr, std::endl;
int main (int Beren, char * Luthien[])
{
   double x = 0.0;
   double y = 0.0;
   double z = 0.0;
   double C = 0.0;
   if (4 != Beren)
   {
      cerr << "Must have 3 arguments!" << endl;
      exit(EXIT_FAILURE);
   }
   x = strtod((*(Luthien+1)), NULL);
   y = strtod((*(Luthien+2)), NULL);
   z = strtod((*(Luthien+3)), NULL);
   C = x/y-z;
   cout << C << endl;
   exit(EXIT_SUCCESS);
}