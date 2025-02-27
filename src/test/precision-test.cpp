// precision-test.cpp
#include <iostream>
#include <iomanip>
#include <cmath>
using namespace std;
int main (void)
{
   cout << "Pi to 15 significant digits: "
        << setprecision(15)
        << M_PI << endl;
   cout << "Pi to  3 significant digits: "
        << setprecision(3)
        << M_PI << endl;
   return 0;
}