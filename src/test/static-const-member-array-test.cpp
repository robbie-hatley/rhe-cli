// static-const-member-array-test.cpp

#include <iostream>

struct asdf
{
  static const double blat[3][5];
};

const double asdf::blat[3][5]=
{
  {1.3, 8.4, 2.9, 4.5, 5.7},
  {9.4, 7.3, 0.1, 0.0, 9.8},
  {2.2, 3.8, 8.4, 7.3, 7.4}
};

int main()
{
  std::cout << asdf::blat[1][1] << std::endl;
  return 0;
}
