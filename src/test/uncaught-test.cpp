#include <iostream>
using namespace std;

int ex_count = 0;

int foo();

struct object {

 ~object() { foo(); }

};

int foo()
{

  int ex = ex_count++;

  try {

    if ( ex < 10 ) {

      // Nah, I want MORE active exceptions ;-)
      object obj;

      cout << "throw " << ex << endl;

      throw ex;

    }
    else {

      cout << "Okay... ENOUGH active exceptions! ;-)" << endl;

    } 
  }
  catch( int ex_caught ) {

    cout << "caught " << ex_caught << endl;

  }

  return ex;

}

int main()
{
  return foo();
}

