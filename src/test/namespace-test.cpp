#include <iostream>

namespace bingo {
  double dumbass1(double blat);
  // double dumbass2(double blat);
}

double bingo::dumbass1(double blat) {
  return 3.7*blat;
}

using namespace std;
using namespace bingo;

int main(int argc, char *argv[])
{
  double trouble=dumbass1(54.2);  
  cout << trouble << endl;
  return 0;
}


/*
double dumbass2(double blat) {
  return dumbass1(blat)-8.2;
}
*/
