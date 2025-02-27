#include <iostream>

using std::cout;
using std::endl;

class Constant {
  public:
    Constant( ) : ID(++count) { }
    Constant(const Constant& src) : ID(src.ID) { }
    Constant& operator=(const Constant& src) {
      ID = src.ID;
      return(*this);
    }
    bool operator==(const Constant& toCompare) {
      return(ID == toCompare.ID);
    }
    bool operator!=(const Constant& toCompare) {
     return(ID != toCompare.ID);
    }
  private:
    long ID;
    static long count;
};

long Constant::count = -1;

int main()
{
  cout << "Generating unique C1 and C2..." << endl;
  Constant C1;
  Constant C2;
  cout << "Copy constructing C3 from C1..." << endl;
  Constant C3 (C1);
  if ( C1 == C2 ) {
    cout << "C1 is equal to C2." << endl;
  }
  if ( C1 != C2) {
    cout << "C1 is not equal to C2." << endl;
  }
  if ( C1 == C3 ) {
    cout << "C1 is equal to C3." << endl;
  }
  if ( C1 != C3 ) {
    cout << "C1 is not equal to C3." << endl;
  }
  cout << "Assigning C1 to C2..." << endl;
  C2 = C1;
  if ( C1 == C2 ) {
    cout << "C1 is equal to C2." << endl;
  }
  if ( C1 != C2) {
    cout << "C1 is not equal to C2." << endl;
  }
  return(0);
}

