#include <iostream>
using namespace std;
int main (void) {
  int* blat_p = new int;
  (*blat_p) = 42;
  cout << "value is " << *blat_p << endl;
  cout << "address is " << blat_p << endl;
  delete blat_p;
  return 0;
}
