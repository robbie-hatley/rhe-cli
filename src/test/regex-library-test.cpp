
// regex-library-test.cpp

#include <iostream>

#include "rhregex.hpp"

using std::cout;
using std::cerr;
using std::endl;

int main (int Beren, char ** Luthien)
{
   if (5 != Beren)
   {
      cerr 
        << "Error in regex-cpp-test.cpp: this program takes 4 arguments," << endl
        << "but you only typed " << Beren << ". Aborting program."        << endl;
      exit(666);
   }
   std::string Pattern     {Luthien[1]};
   std::string Replacement {Luthien[2]};
   std::string Text        {Luthien[3]};
   std::string Flags       {Luthien[4]};

   std::string Result;

   Result = rhregex::SubstituteCPP(Pattern, Replacement, Text, Flags);
   cout << "CPP Result = " << endl
        << Result          << endl;

   Result = rhregex::SubstituteC(Pattern, Replacement, Text, Flags[0]);
   cout << "C   Result = " << endl
        << Result          << endl;
}
