#include <iostream>
using namespace std;
int main(int argc, char * argv[]) {
  int *blat;     // create int-pointer blat
  blat=new int;  // create new, unnamed int variable pointed-to by blat
  *blat=37;      // store 37 in that variable
  cout << "blat="<< blat << "   *blat=" << *blat << "\n";
  delete blat;   // delete the variable pointed-to by blat
  cout << "blat="<< blat << "   *blat=" << *blat << "\n";
  return 0;
}
