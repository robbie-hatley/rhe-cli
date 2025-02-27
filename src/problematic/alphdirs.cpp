/****************************************************************************\
 * File name:     alphdirs.cpp
 * Title:         Alphabetic Directory Creator
 * Author:        Robbie Hatley.
 * Date Written:  Sun Feb 23, 2003.
 * Inputs:        If a "-h" or "--help" flag is present, prints help and exits.
 * Outputs:       Creates directories !symbol, 0-9, a-z in current directory.
 * To make:       Link with rhutil.o
 * Edit history:
 *    Sun Feb 23, 2003 - Wrote it.
 *    Wed Aug 24, 2005 - Added help.
 *    Wed Sep 14, 2005 - Got rid of dependency on rhutil.
\****************************************************************************/

#include <sys/stat.h>

#include <iostream>
#include <string>

#include "rhutil.hpp"

using std::cout;
using std::endl;

void AlphDirs (void);
void Help     (void);

int main (int Elbereth, char* Gilthoniel[])
{
   if (rhutil::HelpDecider(Elbereth, Gilthoniel, Help)) return 777;
   AlphDirs();
   return 0;
}

void AlphDirs (void)
{
   // Make a 2-element char array to hold a 1-character null-terminated path string:
   char Path [2] = "-";

   // Make a 11-element char array to hold a 10-character null-terminated digits string:
   const char Digits  [11] = "0123456789";

   // Make a 27-element char array to hold a 26-character null-terminated letters string:
   const char Letters [27] = "abcdefghijklmnopqrstuvwxyz";

   // make !#$%&_Symbols directory:
   mkdir("!#$%@_", 0); // Read-only.  (To disable, use S_IWUSR instead of 0.)

   // make 0-9 directories:
   for(short int i=0; i<10; ++i)
   {
      Path[0] = Digits[i];
      mkdir(Path, 0); // Read-only.  (To disable, use S_IWUSR instead of 0.)
   }

   // make a-z directories:
   for(short int i=0; i<26; ++i)
   {
      Path[0] = Letters[i];
      mkdir(Path, 0); // Read-only.  (To disable, use S_IWUSR instead of 0.)
   }

   return;
}

void Help (void)
{
   cout
   << "Welcome to alphdirs.exe, Robbie Hatley's alphabetical-directory-set"   << endl
   << "creation utility."                                                     << endl
                                                                              << endl
   << "This version was compiled at " << __TIME__ << " on "<< __DATE__ << "." << endl
                                                                              << endl
   << "alphdirs.exe ignores any arguments except for -h or --help ."          << endl
                                                                              << endl
   << "alphdirs.exe will create the following empty subdirectories in"        << endl
   << "the current directory:"                                                << endl
   << " 1 Directory   named !#$%&_"                                           << endl
   << "10 Directories named 0 through 9"                                      << endl
   << "26 Directories named a through z"                                      << endl;
   return;
}
