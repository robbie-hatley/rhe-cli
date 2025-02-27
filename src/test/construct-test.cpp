#include <iostream>

using std::cout;
using std::endl;

template<class T, class U>
class Foo
{
   public:
      T Blat;
      U Splat;
};

int main()
{
   Foo<char, double> Andren1;
   Foo<char, double> Andren2 = Foo<char, double>();
   Andren1.Blat = 'c';
   Andren1.Splat = 37.5;
   cout << "char element   = " << Andren1.Blat  << endl;
   cout << "double element = " << Andren1.Splat << endl;
   return 0;
}
