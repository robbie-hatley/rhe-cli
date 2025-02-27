// StripNumerators-test

#include <iostream>
#include <string>
#include "rhdir.hpp"

using std::cout;
using std::endl;
using std::string;

int main(int, char* Blat[])
{
   cout << rhdir::Denumerate(string(Blat[1])) << endl;
   return 0;
}
