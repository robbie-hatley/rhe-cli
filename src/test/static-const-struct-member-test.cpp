#include <iostream>
struct C {
  static const int N = 10;
};

int main() {
  int i = C::N; // ill-formed, definition of C::N required
  std::cout << "i = " << i << std::endl;
}
