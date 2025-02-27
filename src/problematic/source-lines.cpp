/************************************************************************************************************\
 * Program name:  Source-Lines
 * Description:   Counts lines of C or C++ source code (incl. headers) in a directory tree.
 * File name:     source-lines.cpp
 * Source for:    source-lines.exe
 * Author:        Robbie Hatley
 * Date written:  Fri. Oct. 22, 2004
 * Inputs:        None
 * Outputs:       Prints total lines of code in source-code tree to std. output.
 * To make:       Link with rhutil.o and rhdir.o in librh.a
 * Edit History:
 *    Fri Oct 22, 2004 - started writing it
 *    Sat Oct 23, 2004 - got it sort-of working
 *    Sun Oct 24, 2004 - now fully functional
 *    Sat Nov 20, 2004 - Renamed to source-lines; added *.rc files
 *    Sat Nov 20, 2004 - Restructured, added expandable vector of types
 *    Sat Apr 23, 2005 - Simplified, eliminating unnecessary functions and functors
 *    Thu Aug 25, 2005 - Dramatically simplified, going away from object-oriented approach and back to a
 *                       purely procedural, structured-programming approach, which works MUCH better for
 *                       this kind of program.
\************************************************************************************************************/

#include <iostream>
#include <string>
#include <vector>
#include <list>
#include <algorithm>

#include <dir.h>

#include "rhutil.hpp"
#include "rhdir.hpp"

namespace ns_SourceLines
{
   using std::cout;
   using std::endl;

   void CountLines (void);
   void CountType  (std::string const & Type);
   void Help       (void);

   unsigned long int SourceLineCount = 0;
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
// main():                                                                                                  //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

int main(int Legolas, char* Gimli[])
{
   using namespace ns_SourceLines;
   if (rhutil::HelpDecider(Legolas, Gimli, Help)) return 777;
   rhdir::RecursionDecider(Legolas, Gimli, CountLines);
   cout << "Number of lines of C/C++ source code = " << SourceLineCount << endl;
   return 0;
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//  void ns_SourceLines::CountLines(void)                                                                   //
//                                                                                                          //
//  Counts lines of source code in source-code files of all types in current directory.                     //
//  Increments global variable SourceLineCount by this subtotal.                                            //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void
ns_SourceLines::
CountLines
   (
      void
   )
{
   // Make vector of file types we consider to be "source code files":
   std::vector<std::string> Extensions;
   Extensions.reserve(20);

   Extensions.push_back("*.c")   ; // C source code file
   Extensions.push_back("*.cpp") ; // C++ source code file
   Extensions.push_back("*.hpp")   ; // C/C++ header file
   Extensions.push_back("*.rc")  ; // MS-VC++6.0 resource template file

   for_each(Extensions.begin(), Extensions.end(), CountType);
   return;
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//  void ns_SourceLines::CountType(std::string const & Type)                                                //
//                                                                                                          //
//  Counts lines of source code in all source-code files of the given type in current directory.            //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void
ns_SourceLines::
CountType
   (
      std::string const & Type
   )
{
   // Make list of file records for all files of this type in this directory:
   std::list<rhdir::FileRecord> Files;
   rhdir::LoadFileList(Files, Type);

   // For each file, increment global variable SourceLineCount by number of lines of source code in file:
   std::list<rhdir::FileRecord>::iterator j;
   for (j=Files.begin(); j!=Files.end(); ++j)
   {
      SourceLineCount += rhdir::CountLinesInFile(*j);
   }

   return;
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//  void ns_SourceLines::Help(void)                                                                         //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void
ns_SourceLines::
Help
   (
      void
   )
{
   cout
   << "Welcome to source-lines.exe, Robbie Hatley's source-code line counter."         << endl
   << "This version was compiled at " << __TIME__ << " on " << __DATE__ << "."         << endl
                                                                                       << endl
   << "This program counts all lines of source code in all of the source-code files"   << endl
   << "in the current directory (and it's subdirectories if an -r or --recurse switch" << endl
   << "is used) and prints the total to stdout."                                       << endl
                                                                                       << endl
   << "\"Source-code files\" are considered to be any files of the following types:"   << endl
   << "*.c   (C source-code file)"                                                     << endl
   << "*.cpp (C++ source-code file)"                                                   << endl
   << "*.h   (C/C++ header file)"                                                      << endl
   << "*.rc  (MS-VC++6.0 resource template file)"                                      << endl;
   return;
}
