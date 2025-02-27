#include <iostream>
using std::cout;
using std::endl;

class S
{
  public:
    S(int aa) : a(aa) {}
    void f()  {cout << a << endl;} // Missing "const" after "f()"!!!
  private:
    int a;
};

void g(const S& d)                 // Promises that d won't be altered.
{
  d.f();                           // Violates promise!!!  Won't compile.
}

int main()
{
  S s (37);
  g(s);
}
// Generates compile error "Discards qualifiers.".
