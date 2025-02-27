
/******************************************************************************\
 * Program name:  Dir-Names-To-Capital
 * File name:     dir-names-to-capital.cpp
 * Source for:    dir-names-to-capital.exe
 * Author:        Robbie Hatley
 * Date written:  Sunday Nov 11, 2007
 * Description:   Converts the names of all subdirectories of the current
 *                directory (and all subdirectories if a "-r" or "--recurse"
 *                switch is used) to First-Letter-Of-Each-Word-Capitalized case.
 * To make:       Link with modules rhdir.o and rhutil.o in librh.a .
 * Edit history:
 *   Sun Nov 11, 2007 - Wrote it.
 *   Sun Mar 29, 2009 - Coalesced "dir-names-to-robbie" and "folder-names-to-capital"
 *                      into one program, because they had duplicate semantics!
 *                      Unknown how on Earth I managed to write the same program twice.
\******************************************************************************/

#include <cstdlib>
#include <cstring>
#include <cctype>

#include <iostream>
#include <iomanip>
#include <fstream>
#include <list>
#include <string>

#define BLAT_ENABLE
#undef  BLAT_ENABLE

#include "rhutil.hpp"
#include "rhdir.hpp"

namespace ns_DNTC
{
   using std::cin;
   using std::cout;
   using std::cerr;
   using std::endl;

   void DirNamesToCapital(void);
   void Help(void);

   unsigned long int Count = 0;
}

int main (int Vinca, char* Azalea[])
{
   using namespace ns_DNTC;
   if (rhutil::HelpDecider(Vinca, Azalea, Help))
   {
      return 0;
   }
   rhdir::RecursionDecider(Vinca, Azalea, DirNamesToCapital);
   cout
      << "Renamed " << Count
      << " directories to first-letter-of-each-word-capitalized case." << endl;
   return 0;
}

void ns_DNTC::DirNamesToCapital (void)
{
   BLAT("\nJust entered function DirNamesToCapital().\n")
   std::list<rhdir::FileRecord> DirRecords;
   std::list<rhdir::FileRecord>::iterator fri;

   bool            bSuccess     = false;     // success boolean
   std::string     OldName      = "";        // old directory name
   std::string     NewName      = "";        // new directory name

   rhdir::LoadFileList
   (
      DirRecords, // container
      "*",        // all names
      2,          // dirs only
      1           // clear list first
   );

   for (fri = DirRecords.begin(); fri != DirRecords.end(); ++fri)
   {
      BLAT("In DirNamesToCapital.  At top of \"for\" loop.")
      OldName = fri->name;
      NewName = rhutil::StringToRobbie(OldName);

      if (NewName != OldName)
      {
         BLAT("In DirNamesToCapital.  At top of \"if\".")
         ++Count;
         cout
            << endl
            << endl
            << "Rename #" << Count << endl
            << "Old directory name:  " << OldName << endl
            << "New directory name:  " << NewName << endl;
         bSuccess = rhdir::RenameFile(OldName, NewName);
         if (!bSuccess)
         {
            cerr
               << "Error in program \"dir-names-to-capital.exe\"," << endl
               << "in function DNTC::DirNamesToCapital():"         << endl
               << "This directory rename failed:"                  << endl
               << "Old name: " << OldName                          << endl
               << "New name: " << NewName                          << endl
               << "Continuing with next directory."                << endl;
            --Count;
         } // end if (rename was not successful)
      } // end if (NewName != OldName)
   } // end for (each folder record)
   return;
}


void ns_DNTC::Help (void)
{
   cout
   << "Welcome to \"directory-names-to-capital\", Robbie Hatley's nifty "              << endl
   << "directory-name word capitalizer."                                               << endl
   << " "                                                                              << endl
   << "This version was compiled at " << __TIME__ << " on " << __DATE__ << "."         << endl
   << " "                                                                              << endl
   << "This program Converts the names of all subdirectories of the current directory" << endl
   << "(and all its subdirectories, if a \"-r\" or \"--recurse\" switch is used)"      << endl
   << "to \"First Letter Of Each Word Capitalized\" case."                             << endl;
   return;
}
