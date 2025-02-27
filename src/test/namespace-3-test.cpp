#include <iostream>
using std::cout;
using std::endl;

namespace testnamespace
{
    class X
    {
      public:
        void dosomething ();
        int geti() {return i;}
      private:
        int i;
    };
}

using namespace testnamespace;

void X::dosomething ()
{
    i = 123;
}

int main() {
  X x;
  x.dosomething();
  cout << x.geti() << endl;
  return 0;
}
