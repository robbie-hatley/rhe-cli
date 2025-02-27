#undef DEBUG_ENUMERATE
/************************************************************************************************************\
 * File name:       unique-file-names.cpp
 * Source for:      unique-file-names.exe
 * Program name:    Unique File Names
 * Author:          Robbie Hatley
 * Date written:    Sun Mar 09, 2008
 * Notes:           This program renames any files in the current directory (and its subdirectories, if a
 *                  "-r" or "--recurse" switch is used) which contain groups of "+" characters, by replacing
 *                  those groups with a group of 6 random characters from the following 36-character string:
 *                  "abcdefghijklmnopqrstuvwxyz0123456789".  Use a "-h" or "--help" switch to get help.
 * Edit history:    Thu Mar 09, 2008 - Wrote it.
 * To make:         Link with modules "rhutil.o" , "rhdir.o" , and "rhmath.o" in library "librh.a".
\************************************************************************************************************/

#include <iostream>
#include <iomanip>
#include <list>
#include <string>
#include <sstream>

#include <cstdlib>

#include "rhutil.hpp"
#include "rhdir.hpp"
#include "rhmath.hpp"
#include "rhregex.hpp"

namespace ns_UFN
{
   using std::cin;
   using std::cout;
   using std::cerr;
   using std::endl;

   typedef std::list<std::string>                  LS;
   typedef std::list<std::string>::iterator        LSI;
   typedef std::list<rhdir::FileRecord>            LF;
   typedef std::list<rhdir::FileRecord>::iterator  LFI;
   typedef std::vector<std::string>                VS;
   typedef std::vector<std::string>::iterator      VSI;

   void UniqueFileNames(void);
   std::string RandomSix(void);
   void Help(void);
}


int
main
   (
      int Galadriel,
      char* Elbereth[]
   )
{
   using namespace ns_UFN;
   rhmath::Randomize();
   if (rhutil::HelpDecider (Galadriel, Elbereth, Help)) return 0;
   rhdir::RecursionDecider (Galadriel, Elbereth, UniqueFileNames);
   return 0;
}


void
ns_UFN::
UniqueFileNames
   (
      void
   )
{
   // Declare vars:
   LF FileList;
   bool bSuccess = false;
   std::string OldFileName, TmpFileName, NewFileName, RegEx, Replacement;

   // Get list of FileRecords for all files in current directory which contain
   // groups of '+' characters:
   rhdir::LoadFileList(FileList, "*++*");

   // Set RegEx to "\+\++":
   RegEx = std::string("\\+\\++");

   // Rename any files containing regex \+\++ by replacing the match with a
   // group of 6 random characters from "abcdefghijklmnopqrstuvwxyz0123456789":
   for (LFI i = FileList.begin(); i != FileList.end(); ++i)
   {
      OldFileName = i->name;
      NewFileName = OldFileName;

      // Run the replacement IN NON-GLOBAL MODE at least twice, collecting both return values:
      Replacement = RandomSix(); // Use fresh replacement each time.
      TmpFileName = NewFileName = rhregex::Substitute(RegEx, Replacement, NewFileName, 'h');
      Replacement = RandomSix(); // Use fresh replacement each time.
      NewFileName = rhregex::Substitute(RegEx, Replacement, NewFileName, 'h');

      // If the two return values are not the same, keep running the replacement
      // IN NON-GLOBAL MODE until they come out equal:
      while (NewFileName != TmpFileName)
      {
         TmpFileName = NewFileName; // Store old "new" name in TmpFileName.
         Replacement = RandomSix(); // Use fresh replacement each time.
         NewFileName = rhregex::Substitute(RegEx, Replacement, NewFileName, 'h');
      }

      // Add the tag "UNIQUE-" to the front of NewFileName:
      NewFileName = "UNIQUE-" + NewFileName;

      // Make sure that this file name is UNIQUE; if not, print error message and
      // continue on to next file:
      if (rhdir::FileExists(NewFileName))
      {
         cerr
                                                     << endl
         << "Warning from unique-file-names.exe:"    << endl
         << "Cannot perform this rename:"            << endl
         << "Old file name:  " << OldFileName        << endl
         << "New file name:  " << NewFileName        << endl
         << "because new name is same as old name!"  << endl
         << "Continuing with next file..."           << endl;
         continue;
      }

      // Attempt to rename the file:
      bSuccess = rhdir::RenameFile(OldFileName, NewFileName);

      // If attempt failed, print error message and continue on to next file:
      if (!bSuccess)
      {
         cerr
                                                                                 << endl
         << "Warning from unique-file-names.exe:"                                << endl
         << "RenameFile() refused to perform this file rename:"                  << endl
         << "Old file name:  " << OldFileName                                    << endl
         << "New file name:  " << NewFileName                                    << endl
         << "Undoubtedly it had its reasons, bizarre as they might seem to us."  << endl
         << "Continuing with next file..."                                       << endl;
         continue;
      }
   } // End for (each file in FileList)
   return;
}


std::string
ns_UFN::
RandomSix
   (
      void
   )
{
   char chars[37] = "abcdefghijklmnopqrstuvwxyz0123456789";
   std::string Six = "";
   for (int i = 1; i <= 6; ++i)
   {
      Six += chars[rhmath::RandInt(0, 35)];
   }
   return Six;
}


void
ns_UFN::
Help
   (
      void
   )
{
   cout
   << "Welcome to Robbie Hatley's file-name-uniqueifying program,"                       << endl
   << "unique-file-names.exe (hereafter referred to as \"UFN\")."                        << endl
                                                                                         << endl
   << "This version compiled at " << __TIME__ << "on " << __DATE__ << " ."               << endl
                                                                                         << endl
   << "Usage:"                                                                           << endl
   << "   unique-file-names -h | --help         (just prints help)"                      << endl
   << "   unique-file-names [-r | --recurse]    (uniqueifys file names)"                 << endl
                                                                                         << endl
   << "UFN renames any of the files in the current directory (and its subdirectories,"   << endl
   << "if a \"-r\" or \"--recurse\" switch is used) which have names containing"         << endl
   << "clusters of 2 or more \'+\' signs by replacing each such cluster with a group of" << endl
   << "6 random characters from the string \"abcdefghijklmnopqrstuvwxyz0123456789\"."    << endl
                                                                                         << endl
   << "This program is especially useful for repairing file names which have been"       << endl
   << "converted to \"+++++++.jpg\" or the like by simplify-file-names.exe (\"SFN\"),"   << endl
   << "usually because the original file name contained a lot of \"%2A\" hex gibberish," << endl
   << "which SFN turned into plus signs."                                                << endl;

   return;
}
