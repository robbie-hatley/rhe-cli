#include <iostream>
#include <iomanip>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cctype>
#include <cmath>

#undef  NDEBUG
#include <assert.h>
#include <errno.h>

#define BLAT_ENABLE

#include "rhmath.hpp"

using std::cout;
using std::endl;
using rhmath::ctoi;
using rhmath::itoc;

int main (void)
{
   char Char = '6';
   cout << "Char = " << Char << endl;
   int Int  = ctoi(Char);
   cout << "Integer value of Char = " << Int << endl;
   cout << "Numeral representing integer " << Int << " is " << itoc(char(Int)) << endl;
   return 0;
}
