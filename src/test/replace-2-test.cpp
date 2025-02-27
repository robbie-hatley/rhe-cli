#include <iostream>
#include <string>

#define BLAT_ENABLE
#include "rhdefines.h"

using std::string; 
using std::cout; 
using std::endl;

string SubstTest (string const & Text);

int main (void)
{
   string Text0 ("randip.c");
   string Text3 = SubstTest(Text0);
   cout << "Text3 = " << Text3 << endl;
   return 0;
}

string SubstTest (string const & Text)
{
   string Text2 = string(Text);
   string Replacement2 = "or";
   string::size_type RepPos = string::size_type(1);
   string::size_type RepLen = string::size_type(3);
   BLAT("In rhregex::Substitute(), about to do replacement on Text2 with these parameters:")
   BLAT("Text2        = " << Text2)
   BLAT("RepPos       = " << RepPos)
   BLAT("RepLen       = " << RepLen)
   BLAT("Replacement2 = " << Replacement2)
   Text2.replace(RepPos, RepLen, Replacement2);
   BLAT("Text2 after replacement = " << Text2)
   return Text2;
}
