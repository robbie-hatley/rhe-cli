

/************************************************************************************************************\
 * Program name:  Metaprogramming Pow Test
 * Description:   Test of concept of using C++ template metaprogramming to impliment x^y.
 * File name:     metaprogramming-pow-test.cpp
 * Source for:    metaprogramming-pow-test.exe
 * Author:        Robbie Hatley
 * Date written:  Sun May 06, 2007
 * Inputs:        x and y.
 * Outputs:       x^y.
 * Notes:         
 * To make:       Compile and link.  No external dependencies.  Any variant of gcc should work.
 * Edit History:  
 *    
\************************************************************************************************************/

#include <iostream>

#include "rhutil.hpp"

#include "metaprogramming-pow-test.hpp"

template<int A, int B> 
class Pow
{
   public:
      enum {result = A * Pow<A, B-1>::result};
};

template<int A>
class Pow<A, 0>
{
   public:
      enum {result = 1};
};

namespace ns_MyNameSpace 
{
   using std::cin;
   using std::cout;
   using std::cerr;
   using std::endl;
   void Help(void);
}

int 
main
   (
      int    Beren, 
      char*  Luthien[]
   )
{
   using namespace ns_MyNameSpace;
   std::ios_base::sync_with_stdio();
   rhutil::HelpDecider(Beren, Luthien, Help);
   cout << INPUT_ARG_A << " ^ " << INPUT_ARG_B << " = " << Pow<INPUT_ARG_A, INPUT_ARG_B>::result << endl;
   return 0;
}

void 
ns_MyNameSpace::
Help
   (
      void
   )
{
   //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
   cout
   << "Welcome to Metaprogramming Pow Test, Robbie Hatley's test of the concept of"            << endl
   << "using C++ template metaprogramming to calculate x^y."                                   << endl
                                                                                               << endl
   << "This version compiled at " << __TIME__ << " on " << __DATE__ << "."                     << endl
                                                                                               << endl
   << "Command-line syntax:"                                                                   << endl
   << "metaprogramming-pow-test [switches] [arguments] < InputFile > OutputFile"               << endl
                                                                                               << endl
   << "Switch:                          Meaning:"                                              << endl
   << "\"-h\" or \"--help\"             Print help and exit."                                  << endl
   << "\"-r\" or \"--recurse\"          Process all subdirectories."                           << endl
                                                                                               << endl
   << "Arguments:"                                                                             << endl
   << "Two command-line arguments, both of which must be integers.  The first is raised"       << endl
   << "to the power of the second.  Both must be within the range of 2 to 2 billion,"          << endl
   << "and the arguments must be chosen so that the result is also within that range."         << endl;
   return;
}

// end file MyFancyProgram.cpp
