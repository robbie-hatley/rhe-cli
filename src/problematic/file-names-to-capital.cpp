/************************************************************************************************************\
 * Program name:  File-Name First-Letter-Of-Each-Word-Capitalized Enforcer
 * File name:     filenames-to-capital.cpp
 * Source for:    filenames-to-capital.exe
 * Author:        Robbie Hatley
 * Date written:  Sun Dec 02, 2007
 * Description:   Converts all file names in current directory to First-Letter-Of-Each-Word-Capitalized case.
 * To make:       Link with modules rhdir.o and rhutil.o in librh.a
 * Edit history:
 *    Sun Dec 02, 2004 - Wrote it.
\************************************************************************************************************/

#include <cstdlib>
#include <cstring>
#include <cctype>

#include <iostream>
#include <iomanip>
#include <fstream>
#include <list>
#include <string>

#include "rhutil.hpp"
#include "rhdir.hpp"

namespace FNTC
{
   using std::cin;
   using std::cout;
   using std::cerr;
   using std::endl;

   void FileNamesToCapital(void);
   void Help(void);

   unsigned long int Count = 0;
}

int main(int Vinca, char* Azalea[])
{
   using namespace FNTC;
   if (rhutil::HelpDecider(Vinca, Azalea, Help)) return 777;
   rhdir::RecursionDecider(Vinca, Azalea, FileNamesToCapital);
   cout << "Renamed " << Count << " files to first-letter-of-each-word-capitalized case." << endl;
   return 0;
}

void
FNTC::
FileNamesToCapital
(
   void
)
{
   std::list<rhdir::FileRecord> FileRecords;
   std::list<rhdir::FileRecord>::iterator fri;

   bool            bSuccess     = false;     // success boolean
   std::string     OldName      = "";        // old file name
   std::string     NewName      = "";        // new file name
   int             size         = 0;         // size of a file name
   int             i            = 0;         // the ubiquitous "i"

   LoadFileList(FileRecords);

   for (fri = FileRecords.begin(); fri != FileRecords.end(); ++fri)
   {
      OldName = fri->name;
      NewName = OldName;
      size    = NewName.size();
      for ( i = 0 ; i < size ; ++i )
      {
         // If current character is a letter:
         if (isalpha(NewName[i]))
         {
            // If current character is the first (index 0) letter:
            if (0 == i)
            {
               // Force it to upper-case:
               NewName[i] = toupper(NewName[i]);
            }

            // Else current character is not first character.
            else
            {
               // If previous character was a non-letter other than a dot:
               // (I'm excepting a dot so that extentions don't get capitalized.)
               if (!isalpha(NewName[i-1]) && '.' != NewName[i-1])
               {
                  // Upper-case current letter:
                  NewName[i] = toupper(NewName[i]);
               }
               // Else previous character was a letter or a dot:
               else
               {
                  // Lower-case current letter:
                  NewName[i] = tolower(NewName[i]);
               } // end else (previous character was a letter)
            } // end else (not first character)
         } // end if (character is a letter)
      } // end for (each character in file name)

      if (NewName != OldName)
      {
         ++Count;
         cout
            << endl
            << endl
            << "Rename #" << Count << endl
            << "Old file name:  " << OldName << endl
            << "New file name:  " << NewName << endl;
         bSuccess = rhdir::RenameFile(OldName, NewName);
         if (!bSuccess)
         {
            cerr
            << "Error in program \"file-names-to-capital.exe\", in function"   << endl
            << "FNTC::FileNamesToCapital():"                                   << endl
            << "Failed to rename file from"                                    << endl
            << OldName                                                         << endl
            << "to"                                                            << endl
            << NewName                                                         << endl
            << "Continuing with next file."                                    << endl;
            --Count;
         } // end if (rename was not successful)
      } // end if (NewName != OldName)
   } // end for (each file record)
   return;
}


void
FNTC::
Help
(
   void
)
{
   cout
   << "Welcome to \"file-names-to-capital\", Robbie Hatley's nifty file-name word"     << endl
   << "capitalizer."                                                                   << endl
   << " "                                                                              << endl
   << "This version was compiled at " << __TIME__ << " on " << __DATE__ << "."         << endl
   << " "                                                                              << endl
   << "This program Converts the names of all files in current directory to \"First"   << endl
   << "Letter Of Each Word Capitalized\" case.  Use this program with caution,"        << endl
   << "because some file names, especially those of picture files from Webshots.com"   << endl
   << "user galleries, are case-sensitive.  Running this program on such files will"   << endl
   << "remove the information which can allow finding the gallery the pic came from"   << endl
   << "by plugging the unexpurgated file name into a URL in a browser."                << endl;
   return;
}
