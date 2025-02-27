
// regex-test-3.cpp

#include <iostream>
#include <string>
#include "rhregex.hpp"

using std::cout;
using std::endl;

int main (int Beren, char * Luthien[])
{
   std::string Pattern     = "(red)";
   std::string Replacement = "r\\1io";
   std::string Text        = "Fred ate a steak.";
   
   cout << rhregex::Substitute(Pattern, Replacement, Text, 'g') << endl;

   return 0;
}

