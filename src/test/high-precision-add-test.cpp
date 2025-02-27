#include <cstdlib>
#include <cstring>
#include <cctype>
#include <cmath>
#include <iostream>
#include <iomanip>

#include "rhutil.hpp"
#include "rhmath.hpp"

int main(void)
{
   using std::cout;
   using std::endl;
   using std::right;
   using std::setw;
   using namespace rhmath;
   BigNum A ("49385739670915939058158923492344534343210948312");
   BigNum B ("56543028908098080913249854308482340324248320423");
   BigNum C ("0");
   C = A + B;
   cout << right << setw(75) << A << endl;
   cout << right << setw(75) << B << endl;
   cout << right << setw(75) << C << endl;
   return 0;
}
