/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * infinity-test.cpp
 * Tests the ability of C++ variables to handle infinity.
 * Written by Robbie Hatley circa 2002.
 * Last edited Sat. Oct. 23, 2004.
 * To make, just compile; no dependencies.
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <cstring>
#include <cctype>
#include <cmath>
#include <ctime>
#include <new>

int main()
{
  std::ios::sync_with_stdio();
  double a, x, y, z, q;
  x=7.0;
  y=7.0;
  z=7.0;
  q=x/(y-z);
  a=7.3/q;
  std::cout << "q = " << q << "\n";
  std::cout << "a = " << a << "\n";
  return 0;
}

