#include <iostream>

using std::cout;
using std::endl;

int main(int argc, char *argv[])
{
  cout << __FILE__ << " compiled at " << __TIME__;
  cout << " on " << __DATE__ << "." << endl;
  cout << "This line number is " << __LINE__ << "." << endl;
  return 0;
}
