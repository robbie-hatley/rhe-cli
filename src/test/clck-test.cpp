// clcktest.cpp

#include <ctime>
#include <iostream>

using std::cout;
using std::endl;
using std::clock;

int main(int argc, char *argv[])
{
  double ticks = double(CLOCKS_PER_SEC);
  cout << "Clock ticks per second = " 
       << ticks 
       << endl;
  double clock1 = double(clock());
  cout << "clock1 = " 
       << clock1 
       << endl;
  cout << "About to waste some time..." 
       << endl;
  double back=3.302;
  for (int i=0; i<35000000; ++i) {
    back*=1.0017;
  }
  double clock2=double(clock());
  cout << "clock2 = " 
       << clock2 
       << endl;
  cout << "Elapsed time in clock ticks = " 
       << clock2-clock1 
       << endl;
  cout << "Elapsed time in seconds = " 
       << (clock2-clock1)/ticks 
       << endl;
  return 0;
}
