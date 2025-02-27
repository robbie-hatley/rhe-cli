// Note RH 2005-08-23: I apparently started writing this two years ago,
// but neither my library nor my expertise were up to it at the time.
// This looks like a good program idea, though.


// STUB!!!!!



/****************************************************************************\
 * Filename:      merge.cpp
 * Program Name:  Merge
 * Description:   Merges the contents of one directory into another, deleting
 *                duplicate files in the process.
 * Authorship:    Written Saturday August 9, 2003 by Robbie Hatley
 * Last edited:   Saturday August 9, 2003
 * Inputs:        Two command-line arguments:
 *                  arg1:  Source path
 *                  arg2:  Destination path
 * Outputs:       Merges the contents of one directory into another
 * To make:       Link with object rhutil.o in library rhlib.a .
\****************************************************************************/

/****************************************************************************\
 *                  PREPROCESSOR DIRECTIVES:                                *
\****************************************************************************/

// Include old C headers:
#include <cstdlib>
#include <cstring>
#include <cctype>
#include <cmath>
#include <ctime>

// Include new C++ headers:
#include <iostream>
#include <iomanip>
#include <fstream>
#include <vector>
#include <list>
#include <string>
#include <algorithm>
#include <functional>
#include <new>
#include <typeinfo>

// Include platform-dependent headers:
#include <conio.h>

// Include personal class-library headers:
#include "rhutil.hpp"
#include "rhdir.hpp"

/****************************************************************************\
 *                  DECLARATIONS:                                           *
\****************************************************************************/

using std::cin;
using std::cout;
using std::cerr;
using std::endl;
using std::string;
using std::vector;
using std::list;
using std::ifstream;
using std::ofstream;
using std::stringstream;

namespace ns_Merge
{
   using std::cout;
   using std::endl;

   void Merge(std::vector<std::string> const & Args);
   void Help(void);
}

int main(int Peter, char *Paul[])
{
   using namespace ns_Merge;

   if (rhutil::HelpDecider(Peter, Paul, Help)) {return 777;}

   std::vector<std::string> Args;
   rhutil::GetArguments(Peter, Paul, Args);
   Merge(Args);
   return 0;
}

void
ns_Merge::
Merge
   (
      std::vector<std::string> const & Args
   )
{
   cout << "Stub!" << endl;
   return; // Stub!
}


void
ns_Merge::
Help
   (
      void
   )
{
   rhutil::PrintString
   (
      "Welcome to merge, Robbie Hatley's directory-merging program.\n"
      "As of Wed. Jun. 21, 2006, this is a stub.  When finished,\n"
      "it will merge contents from multiple directories into one,\n"
      "automatically numerating file names before merge, erasing\n"
      "duplicates after merge, and denumerating file names.\n"
   );
   return;
}

