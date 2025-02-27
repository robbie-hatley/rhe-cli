#include <iostream>
#include <cstdlib>
using namespace std;
typedef void TFoo();
class A
{
  public:
    TFoo f() {};
};
int main() {
  A.f();
  return 0;
}
