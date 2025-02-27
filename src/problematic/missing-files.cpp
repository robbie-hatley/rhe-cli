/************************************************************************************************************\
 * Program name:  Missing-Files
 * Description:   Displays those file names in a numbered series which do NOT represent files which actually
 *                exist in the current directory.
 * File name:     missing-files.cpp
 * Source for:    missing-files.exe
 * Author:        Robbie Hatley
 * Date written:  Thu Aug 11, 2005.
 * Inputs:        Three command-line arguments.  (See "Help()" function below for details.)
 * Outputs:       Names of missing files.
 * To make:       link with rhutil.o and rhdir.o
 * Edit History:
 *   Thu Aug 11, 2005 - Wrote it.
 *   Mon Aug 23, 2005 - Simplified it, and wrote a bunch of comments.
 *   Sun Dec 04, 2005 - Drastically simplified and improved.
 *   Wed Nov 24, 2010 - Fixed bug that crept in when I changed LoadList for strings to include full path.
\************************************************************************************************************/

#include <cmath>

#include <iostream>
#include <iomanip>
#include <sstream>
#include <list>
#include <vector>
#include <string>
#include <functional>

#include <unistd.h>

#undef DEBUG
//#define DEBUG

#if defined DEBUG
#define BLAT_ENABLE
#else
#undef BLAT_ENABLE
#endif

#include "rhutil.hpp"
#include "rhdir.hpp"

typedef std::vector<std::string> VS;

namespace ns_MissingFiles
{
   using std::cin;
   using std::cout;
   using std::cerr;
   using std::endl;
   using std::flush;

   class SignatureNonMatch : public std::unary_function<std::string, bool>
   {
      public:
         SignatureNonMatch(std::string const & RefSig) : RefSig_(RefSig) {}
         bool operator()(std::string const & FileName)
         {
            BLAT("In SignatureNonMatch() operator.")
            BLAT("FileName = " << FileName)
            BLAT("rhdir::Signature(FileName) = " << rhdir::Signature(FileName))
            BLAT("RefSig_ = " << RefSig_)
            return RefSig_ != rhdir::Signature(FileName);
         }
      private:
         std::string RefSig_;
   };

   void
   SetVars
      (
         VS const & Arguments
      );

   void
   MissingFiles
      (
         void
      );

   void
   Help
      (
         void
      );

   std::string  Root;
   int          ANum;
   int          ZNum;
}


int main(int Tirith, char* Ithil[])
{
   using namespace ns_MissingFiles;

   if (rhutil::HelpDecider(Tirith, Ithil, Help)) {return 777;}

   VS Arguments;
   rhutil::GetArguments(Tirith, Ithil, Arguments);
   SetVars(Arguments);

   MissingFiles();

   return 0;
}


void
ns_MissingFiles::
SetVars
   (
      VS const & Arguments
   )
{
   Root = Arguments[0];
   ANum = atoi(Arguments[1].c_str());
   ZNum = atoi(Arguments[2].c_str());
   BLAT("Root: " << Root)
   BLAT("ANum: " << ANum)
   BLAT("ZNum: " << ZNum)
   return;
}



void
ns_MissingFiles::
MissingFiles
   (
      void
   )
{
   BLAT("Just entered MissingFiles(); about to get file list.")

   // Get a std::list<rhdir::FileRecord> so we have dir, names, attributes, etc available:
   std::list<rhdir::FileRecord> Files;
   rhdir::LoadFileList(Files);

   BLAT("Got std::list<rhdir::FileRecord> Files.  Files.size() = " << Files.size())
   BLAT("About to get list of file names.")

   // Get separate list of names of files (no paths, just file names, so we can do
   // signature matching; and a plain std::list<std::string> so we can sort it):
   std::list<std::string> FileNames;
   std::list<rhdir::FileRecord>::iterator FileIter;
   for ( FileIter = Files.begin() ; FileIter != Files.end() ; ++FileIter )
   {
      FileNames.push_back(FileIter->name);
   }
   
   BLAT("Got list of file names.  FileNames.size() = " << FileNames.size())

   // Remove any file names that don't match the signature of Root:
   BLAT("About to strip non-matching files.  FileNames.size() = " << FileNames.size())
   FileNames.remove_if(SignatureNonMatch(rhdir::Signature(Root)));
   BLAT("Just stripped  non-matching files.  FileNames.size() = " << FileNames.size())

   // Sort list of file names:
   FileNames.sort();

   // Iterate through list of file names:
   long PrevNumber = ANum - 1;
   long CurrNumber = 0;
   std::list<std::string>::iterator FileNameIter;
   for ( FileNameIter = FileNames.begin() ; FileNameIter != FileNames.end() ; ++FileNameIter )
   {
      BLAT("At top of main file for loop.")

      BLAT("Current file name = " << *FileNameIter)

      // Set "CurrNumber" to numerical part of name of current file:
      CurrNumber = atoi((rhdir::Number(*FileNameIter)).c_str());

      BLAT("CurrNumber = " << CurrNumber)

      // Only consider file numbers in closed interval [ANum,ZNum] :
      if (CurrNumber < ANum) continue; // haven't reached start of check zone
      if (CurrNumber > ZNum) break;    // all finished

      // Print any numbers greater than PrevNumber but smaller than CurrNumber.
      // This should only print the numbers of missing files:
      for (int i = PrevNumber + 1; i < CurrNumber; ++i)
      {
         cout << i << endl;
      }
      PrevNumber = CurrNumber;

      BLAT("About to exit main file for loop.")
   } // End for (each file name in list of file names).

   // At this point, we've found any missing files with numbers less than 
   // the last existing file found; but what about missing files with numbers
   // *greater than* the last existing file found?
   if (CurrNumber < ZNum)
   {
      // Print the numbers of any missing files after the last file found:
      for (int i = CurrNumber + 1; i <= ZNum; ++i)
      {
         cout << i << endl;
      }
   }
   return;
}




void
ns_MissingFiles::
Help
   (
      void
   )
{
   cout <<
   "Welcome to \"missing-files\", Robbie Hatley's nifty program for determining which\n"
   "(if any) files are missing from a numerated set of files, such as:\n"
   "\"BritSprsNud001.jpg\", \"BritSprsNud002.jpg\", \"BritSprsNud003.jpg\", etc.\n"
   "\n"
   "This version was compiled at " __TIME__ " on " __DATE__ ".\n"
   "\n"
   "Usage:\n"
   "missing-files FileNameRoot FirstNumber LastNumber  (to print missing file names)\n"
   "missing-files [-h|--help]                          (to get help)\n"
   "\n"
   "FileNameRoot must be the name of one of the files in the series with the digits\n"
   "replaced by octothorpes (\'#\').\n"
   "\n"
   "FirstNumber must be the first number of the series.\n"
   "\n"
   "LastNumber must be the last number of the series.\n"
   "\n"
   "Missing-Files will then print a list of all the file names with the given root\n"
   "name, in the given range, which do NOT actually exist in the current directory.\n"
   "\n"
   "Example: If you have a series of files which should span from \"Naughty0001.jpg\"\n"
   "to \"Naughty0397.jpg\", then the following should print the names of any files in\n"
   "the series which do NOT actually exist in your current directory:\n"
   "missing-files Naughty####.jpg 1 397\n"
   "\n"
   "The digits of the file names don't have to be contiguous.  However, if they're\n"
   "not, then the results of running missing-files can be surprising, because all\n"
   "the digits are run together in the program to get the \"number\" of a file.\n"
   "For example, the number of file \"LDeCap37-035.jpg\" is 37035.  Therefore,\n"
   "if subseries 37 runs from 1 to 87 and subseries 38 runs from 1 to 275, then\n"
   "missing-files will report 913 missing files between \"LDeCap37-087.jpg\" and\n"
   "\"LDeCap38-001.jpg\", even though there are really ZERO missing files.  Hence in\n"
   "cases like this, it's best to run missing-files separately for each subseries.\n"
   << flush;
   return;
}
