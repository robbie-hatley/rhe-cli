/****************************************************************************************\
 * Program name:  Source Clean
 * Description:   Removes C/C++ intermediate and output files from current directory,
 *                and it's subdirectories if the -r or --recurse switch is used.
 * File name:     source-clean.cpp
 * Source for:    source-clean.exe
 * Author:        Robbie Hatley
 * Date written:  Thu. Nov. 18, 2004 - Started development.
 * Edited:        Sat. Nov. 20, 2004 - Got it working, for *.obj only.
 * Edited:        Sat. Nov. 20, 2004 - Added RemoveType; added more types.
 * Inputs:        None.
 * Outputs:       Deletes intermediate files.
 * To make:       Link with rhutil.o and rhdir.o in librh.a .
\****************************************************************************************/


// ============= PREPROCESSOR DIRECTIVES: ================================================

#include <iostream>
#include <string>
#include <vector>
#include <list>
#include <algorithm>

#include <dir.h>

#include "rhutil.hpp"
#include "rhdir.hpp"


// ============= DECLARATIONS: ===========================================================

namespace ns_SourceClean
{
   using std::cout;
   using std::endl;

   void RemoveFiles (void);
   void EraseType   (std::string Type);
   void EraseFile   (const rhdir::FileRecord& F);
   void Help        (void);
}


// ============= Function Definitions: ===================================================


//////////////////////////////////////////////////////////////////////////////////////////
//
// main():
//
//////////////////////////////////////////////////////////////////////////////////////////
int main(int Frank, char* Honest[])
{
   using namespace ns_SourceClean;
   if (rhutil::HelpDecider(Frank, Honest, Help)) return 777;
   rhdir::RecursionDecider(Frank, Honest, RemoveFiles);
   return 0;
}


//////////////////////////////////////////////////////////////////////////////////////////
//
// RemoveFiles():
//
//////////////////////////////////////////////////////////////////////////////////////////
void
ns_SourceClean::
RemoveFiles
   (
      void
   )
{
   std::vector<std::string> Extensions;
   Extensions.reserve(20);

   #define Extension(X) Extensions.push_back(std::string(X))

   Extensions.push_back("*.exe"); // executable file
   Extensions.push_back("*.o"  ); // object file
   Extensions.push_back("*.obj"); // MS-VC++6.0 object file
   Extensions.push_back("*.ilk"); // MS-VC++6.0 intermediate file
   Extensions.push_back("*.pdb"); // MS-VC++6.0 program database file
   Extensions.push_back("*.pch"); // MS-VC++6.0 intermediate file
   Extensions.push_back("*.sbr"); // MS-VC++6.0 intermediate file
   Extensions.push_back("*.bsc"); // MS-VC++6.0 browse info file
   Extensions.push_back("*.res"); // MS-VC++6.0 resource file

   for_each(Extensions.begin(), Extensions.end(), EraseType);

   return;
}



//////////////////////////////////////////////////////////////////////////////////////////
//
// EraseType():
//
//////////////////////////////////////////////////////////////////////////////////////////
void
ns_SourceClean::
EraseType
   (
      std::string Type
   )
{
   std::list<rhdir::FileRecord> Files;
   rhdir::LoadFileList(Files, Type);
   for_each(Files.begin(), Files.end(), EraseFile);
}



//////////////////////////////////////////////////////////////////////////////////////////
//
// EraseFile():
//
//////////////////////////////////////////////////////////////////////////////////////////
void
ns_SourceClean::
EraseFile
   (
      const rhdir::FileRecord& F
   )
{
   remove(F.name.c_str());
   return;
}



//////////////////////////////////////////////////////////////////////////////////////////
//
// Help():
//
//////////////////////////////////////////////////////////////////////////////////////////
void
ns_SourceClean::
Help
   (
      void
   )
{
   cout
   << "Welcome to source-clean.exe, Robbie Hatley's intermediate-file remover." << endl
   << "This version was compiled at " << __TIME__ << " on " << __DATE__ << "." << endl
   << endl
   << "This program erases all files from the current directory (and it's " << endl
   << "subdirectories, if a -r or --recurse switch is used) of the following types: " << endl
   << "*.exe  (executable file)" << endl
   << "*.o    (object file)" << endl
   << "*.obj  (MS-VC++6.0 object file)" << endl
   << "*.ilk  (MS-VC++6.0 intermediate file)" << endl
   << "*.pdb  (MS-VC++6.0 program database file)" << endl
   << "*.pch  (MS-VC++6.0 intermediate file)" << endl
   << "*.sbr  (MS-VC++6.0 intermediate file)" << endl
   << "*.bsc  (MS-VC++6.0 browse info file)" << endl
   << "*.res  (MS-VC++6.0 resource file)" << endl
   << "No other file type is erased.  This program is esp. useful for users of " << endl
   << "Microsoft's Visual Studio, but is also useful for other development " << endl
   << "platforms as well." << endl;
   return;
}
