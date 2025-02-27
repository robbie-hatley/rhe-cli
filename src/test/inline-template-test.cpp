#include <iostream>

using std::cout;
using std::endl;

class MyUtils
{
   public:
      static inline void doStuff() const
      {
         doThis() {cout << "This." << endl;}
         doThat() {cout << "That." << endl;}
      }
}

int main()
{
   MyUtils::doStuff();
   return 0;
}
