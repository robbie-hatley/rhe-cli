#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cctype>
#include <cmath>

#include <iostream>
#include <vector>
#include <string>

#include "rhmath.hpp"

using std::cout;
using std::endl;

int main(void)
{
   rhmath::BigNum a = rhmath::BigNum(37);
   rhmath::BigNum b = rhmath::BigNum(18);
   rhmath::BigNum d = rhmath::BigNum(64);
   rhmath::BigNum e = rhmath::BigNum(92);
   cout << "a   = " <<  a  << endl;
   cout << "b   = " <<  b  << endl;
   cout << "a-b = " << a-b << endl;
   //cout << "d   = " <<  d  << endl;
   //cout << "e   = " <<  e  << endl;
   //cout << "d-e = " << d-e << endl;
   return 0;
}
