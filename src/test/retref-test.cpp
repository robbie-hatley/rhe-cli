#include <iostream>

int &fun(int i) {
  static int asdf;
  if (i==7) {
    std::cout << "asdf=" << asdf << std::endl;
  }
  return asdf;
}

int main(void)
{
  fun(7);
  fun(6)=35;
  fun(7);
  fun(6)=99;
  fun(7);
  return 0;
}
