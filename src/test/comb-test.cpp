// comb-test.cpp
#include <iostream>
#include "rhmath.hpp"
using std::cout;
using std::endl;
using rhmath::Comb;
int main (void) {
   cout << "52-comb-5:        " << Comb(52, 5)                 << endl;
   cout << "0-comb-0:         " << Comb( 0, 0)                 << endl;
   cout << "1-comb-0:         " << Comb( 1, 0)                 << endl;
   cout << "1-comb-1:         " << Comb( 1, 1)                 << endl;
   cout << "2-comb-0:         " << Comb( 2, 0)                 << endl;
   cout << "2-comb-1:         " << Comb( 2, 1)                 << endl;
   cout << "2-comb-2:         " << Comb( 2, 2)                 << endl;
   cout << "3-comb-0:         " << Comb( 3, 0)                 << endl;
   cout << "3-comb-1:         " << Comb( 3, 1)                 << endl;
   cout << "3-comb-2:         " << Comb( 3, 2)                 << endl;
   cout << "3-comb-3:         " << Comb( 3, 3)                 << endl;
   cout << "4-comb-0:         " << Comb( 4, 0)                 << endl;
   cout << "4-comb-1:         " << Comb( 4, 1)                 << endl;
   cout << "4-comb-2:         " << Comb( 4, 2)                 << endl;
   cout << "4-comb-3:         " << Comb( 4, 3)                 << endl;
   cout << "4-comb-4:         " << Comb( 4, 4)                 << endl;
   cout << "5-comb-0:         " << Comb( 5, 0)                 << endl;
   cout << "5-comb-1:         " << Comb( 5, 1)                 << endl;
   cout << "5-comb-2:         " << Comb( 5, 2)                 << endl;
   cout << "5-comb-3:         " << Comb( 5, 3)                 << endl;
   cout << "5-comb-4:         " << Comb( 5, 4)                 << endl;
   cout << "5-comb-5:         " << Comb( 5, 5)                 << endl;
   cout << "6-comb-0:         " << Comb( 6, 0)                 << endl;
   cout << "6-comb-1:         " << Comb( 6, 1)                 << endl;
   cout << "6-comb-2:         " << Comb( 6, 2)                 << endl;
   cout << "6-comb-3:         " << Comb( 6, 3)                 << endl;
   cout << "6-comb-4:         " << Comb( 6, 4)                 << endl;
   cout << "6-comb-5:         " << Comb( 6, 5)                 << endl;
   cout << "6-comb-6:         " << Comb( 6, 6)                 << endl;
   cout << "7-comb-0:         " << Comb( 7, 0)                 << endl;
   cout << "7-comb-1:         " << Comb( 7, 1)                 << endl;
   cout << "7-comb-2:         " << Comb( 7, 2)                 << endl;
   cout << "7-comb-3:         " << Comb( 7, 3)                 << endl;
   cout << "7-comb-4:         " << Comb( 7, 4)                 << endl;
   cout << "7-comb-5:         " << Comb( 7, 5)                 << endl;
   cout << "7-comb-6:         " << Comb( 7, 6)                 << endl;
   cout << "7-comb-7:         " << Comb( 7, 7)                 << endl;
   return 0;
}
