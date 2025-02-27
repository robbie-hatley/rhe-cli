// div2-test.cpp
#include <iostream>
#include <iomanip>
using namespace std;
int main ( int Beren , char * Luthien[] )
{
   if (3 != Beren) {return 666;}
   double a = strtod(Luthien[1], NULL);
   double b = strtod(Luthien[2], NULL);
   double c = a / b;
   cout << setprecision(2) << c << endl;
   return 0;
}