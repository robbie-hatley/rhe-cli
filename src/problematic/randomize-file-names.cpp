
/****************************************************************************\
 * File name:       randomize-file-names.cpp                                *
 * Source for:      randomize-file-names.exe                                *
 * Program name:    Randomize File Names                                    *
 * Author:          Robbie Hatley                                           *
 * Date written:    Thu Mar 02, 2006                                        *
 * Action:                                                                  *
 *   This program renames all of the files in each directory to which it    *
 *   is applied to names with the same suffixes (extensions) as before,     *
 *   but new prefixes consisting of random octets of characters from the    *
 *   36-element character set "0123456789abcdefghijklmnopqrstuvwxyz".       *
 *   WARNING: THIS WILL PERMANANTLY DESTROY ALL OF THE ORIGINAL FILE-NAME   *
 *   INFORMATION!  BE VERY SURE THAT YOU ACTUALLY WANT TO DO THIS!          *
 *                                                                          *
 *   Note: This program is very good for renaming files where the original  *
 *   names are already destroyed, or are gibberish, or are meaningless.     *
 *   Example: a bunch of files with names like "DSCN00385735.jpg" generated *
 *   by a digital camera.  The names are too long and ugly and meaningless; *
 *   my random names actually look better, and convey no less information   *
 *   (ie, none whatsoever).                                                 *
 *                                                                          *
 * Switches and arguments:                                                  *
 *   Prints help and exits if a "-h" or "--help" switch is used.            *
 *   Processes all subdirectories, if a "-r" or "--recurse" switch is used. *
 *   All other arguments are construed as being wildcards; if one or more   *
 *   wildcards are used, only those files matching the wildcard(s) will     *
 *   have their names randomized.
 *                                                                          *
 * To make: Link with modules rhutil.o , rhdir.o , rhmath.o in librh.a      *
 * Edit history:                                                            *
 *   Thu Mar 02, 2006 - Wrote it.                                           *
 *   Mon Mar 23, 2009 - Restructured using ProcessCurDirFunctor.            *
 *                      Moved Flags, Arguments, and FileList to main().     *
 *                      Now uses no global variables whatsoever.            *
\****************************************************************************/

#include <iostream>
#include <iomanip>
#include <list>
#include <string>
#include <sstream>

#include <cstdlib>

#include "rhutil.hpp"
#include "rhdir.hpp"
#include "rhmath.hpp"

namespace ns_RFN
{
   using std::cout;
   using std::cerr;
   using std::endl;
   using std::setfill;
   using std::setw;

   typedef  std::list<std::string>    LS;
   typedef  LS::iterator              LSI;
   typedef  LS::const_iterator        LSCI;
   typedef  std::vector<std::string>  VS;
   typedef  VS::iterator              VSI;
   typedef  VS::const_iterator        VSCI;
   typedef  rhdir::FileRecord         FR;
   typedef  std::list<FR>             LF;
   typedef  LF::iterator              LFI;
   typedef  LF::const_iterator        LFCI;
   typedef  std::vector<FR>           VF;
   typedef  VF::iterator              VFI;
   typedef  VF::const_iterator        VFCI;

   struct Bools_t     // program boolean settings
   {
      bool bHelp;     // Did user ask for help?
      bool bRecurse;  // Walk directory tree downward from current node?
   };

   void
   ProcessFlags
   (
      VS           const  &  Flags,
      Bools_t             &  Bools
   );

   struct Stats_t     // program run-time statistics
   {
      uint32_t  DirCount;  // How many directories did we process?
      uint32_t  RanCount;  // How many file names did we randomize?
      void PrintStats (void);
   };

   class ProcessCurDirFunctor
   {
      public:
         ProcessCurDirFunctor
            (
               Bools_t  const  &  Bools_,
               VS       const  &  Arguments_,
               Stats_t         &  Stats_,
               VF              &  FileList_
            )
            : Bools(Bools_), Arguments(Arguments_), Stats(Stats_), FileList(FileList_)
            {}
         void operator()(void); // defined below
      private:
         Bools_t  const  &  Bools;
         VS       const  &  Arguments;
         Stats_t         &  Stats;
         VF              &  FileList;
   };

   std::string RandomName(void);
   void Help (void);
}


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  main()                                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

int main (int Beren, char * Luthien[])
{
   using namespace ns_RFN;
   srand(time(0));
   VS Flags;
   rhutil::GetFlags (Beren, Luthien, Flags);

   Bools_t Bools = Bools_t();
   ProcessFlags(Flags, Bools);

   if (Bools.bHelp)
   {
      Help();
      return 777;
   }

   VS Arguments;
   rhutil::GetArguments(Beren, Luthien, Arguments);

   Stats_t Stats = Stats_t();
   static VF FileList;
   FileList.reserve(10000);
   ProcessCurDirFunctor ProcessCurDir (Bools, Arguments, Stats, FileList);

   if (Bools.bRecurse)
   {
      rhdir::CursDirs(ProcessCurDir);
   }
   else
   {
      ProcessCurDir();
   }

   Stats.PrintStats();

   return 0;
} // end main()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessFlags()                                                          //
//                                                                          //
//  Sets program-state booleans based on Flags.                             //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_RFN::
ProcessFlags
   (
      VS       const  &  Flags,
      Bools_t         &  Bools
   )
{
   BLAT("\nJust entered ProcessFlags().  About to set Bools.\n")

   // Use InVec from rhutil:
   using rhutil::InVec;

   Bools.bHelp    = InVec(Flags, "-h") or InVec(Flags, "--help"   );
   Bools.bRecurse = InVec(Flags, "-r") or InVec(Flags, "--recurse");

   BLAT("About to return from ProcessFlags.\n")
   return;
} // end ns_MyNameSpace::ProcessFlags()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurDirFunctor::operator()()                                      //
//                                                                          //
//  Processes current directory.                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void ns_RFN::ProcessCurDirFunctor::operator() (void)
{
   BLAT("\nJust entered ProcessCurDir::operator().\n")

   // ABSTRACT:
   // This function randomizes the names of all the files in the current
   // directory (and all its subdirectories, if recursing).

   // Increment directory counter:
   ++Stats.DirCount;

   // Get current directory:
   std::string CurDir = rhdir::GetFullCurrPath();

   // Annouce processing current directory:
   cout
      << "\n"
      << "=================================================================\n"
      << "Directory #" << Stats.DirCount << ":\n"
      << CurDir << "\n"
      << endl;

   // Get vector of file records for all files in current directory which match
   // the wildcards given by the command-line arguments, if any.
   // If no arguments were given, get all files:
   FileList.clear();
   std::string Wildcard;
   if (Arguments.size() > 0)
   {
      for (VS::const_iterator i = Arguments.begin(); i != Arguments.end(); ++i)
      {
         Wildcard = *i;
         rhdir::LoadFileList
         (
            FileList,  // Name of container to load.
            Wildcard,  // File-name wildcard.
            1,         // Files only (not dirs).
            2          // Append to list without clearing.
         );
      }
   }
   else
   {
      rhdir::LoadFileList(FileList); // Get all files.
   }

   BLAT("\nIn ProcessCurDirFunctor::operator().")
   BLAT("Finished building file list.")
   BLAT("File list size is " << FileList.size())
   BLAT("About to enter file-iteration for loop.\n")

   // Randomize the file names:
   bool bSuccess = false;
   std::string OldFileName, NewFileName;
   for ( VFCI i = FileList.begin() ; i != FileList.end() ; ++i )
   {
      OldFileName = i->name;

      // Try at most 25 times to find an unused new file name:
      bSuccess = false;
      int Trial;
      for (Trial=1; Trial<=25; ++Trial)
      {
         std::string RandomFileName = RandomName();
         std::string OldSuffix = rhutil::StringToLower(rhdir::GetSuffix(OldFileName));
         if ("" == OldSuffix)
         {
            NewFileName = RandomFileName;
         }
         else
         {
            NewFileName = RandomFileName + OldSuffix;
         }
         
         bSuccess = !__file_exists(NewFileName.c_str());
         if (bSuccess) break;
      }

      if (bSuccess && Trial > 5)
      {
         cerr
                                                                                          << endl
         << "Warning from randomize-file-names: it took " << Trial << " attempts to find" << endl
         << "an unused new name for this file:"                                           << endl
         << "Old file name: " << OldFileName                                              << endl
         << "New file name: " << NewFileName                                              << endl
                                                                                          << endl;
      }

      if (!bSuccess)
      {
         cerr
                                                                                          << endl
         << "Error in randomize-file-names: unable to create an unused new file name"     << endl
         << "for this file:"                                                              << endl
         << OldFileName                                                                   << endl
         << "even after 25 attempts.  Skipping this directory and moving on to next."     << endl
                                                                                          << endl;
         return;
      }

      bSuccess = rhdir::RenameFile(OldFileName, NewFileName);
      if (bSuccess)
      {
         ++Stats.RanCount;
         cout << OldFileName << " -> " << NewFileName << endl;
      }
      else
      {
         cerr
                                                                                          << endl
         << "Warning from randomize-file-names: this file rename failed:"                 << endl
         << OldFileName << " -> " << NewFileName                                          << endl
         << "Continuing with next file..."                                                << endl
                                                                                          << endl;
      }
   } // End for (each file in FileList)
   return;
} // end ProcessCurDirFunctor::operator()()


std::string ns_RFN::RandomName (void)
{
   char chars[27] = "abcdefghijklmnopqrstuvwxyz";
   std::string Name = "";
   for (int i = 1; i <= 8; ++i)
   {
      Name += chars[rhmath::RandInt(0, 25)];
   }
   return Name;
}


void ns_RFN::Stats_t::PrintStats (void)
{
   cout
                                                      << endl
      << "Finished Randomize-File-Names run."         << endl
      << "Processed  " << DirCount << " directories." << endl
      << "Randomized " << RanCount << " file names."  << endl
                                                      << endl;
   return;
}


void ns_RFN::Help (void)
{
   cout
   << "Welcome to Robbie Hatley's file-name randomizing program,"                        << endl
   << "randomize-file-names.exe (hereafter referred to as \"RFN\")."                     << endl
                                                                                         << endl
   << "This version compiled at " << __TIME__ << "on " << __DATE__ << " ."               << endl
                                                                                         << endl
   << "Usage:"                                                                           << endl
   << "  To print this help and exit:"                                                   << endl
   << "    randomize-file-names -h | --help"                                             << endl
   << "  To randomize file names:"                                                       << endl
   << "    randomize-file-names [-r | --recurse] [wildcard]..."                          << endl
                                                                                         << endl
   << "RFN renames all of the files in the current directory (and its subdirectories,"   << endl
   << "if a \"-r\" or \"--recurse\" switch is used) (but only those files which match"   << endl
   << "the given wildcards, if wildcards were used) to names with the same suffixes as"  << endl
   << "before, but new prefixes consisting of strings of eight random lower-case"        << endl
   << "letters."                                                                         << endl
                                                                                         << endl
   << "This program is especially useful preparatory to consolidating files from"        << endl
   << "multiple directories, preparatory to checking for duplicates, provided you don't" << endl
   << "care about losing the old file names."                                            << endl
                                                                                         << endl
   << "WARNING!!!  IF YOU USE THIS PROGRAM, ALL FILES IN CURRENT DIRECTORY (OR, IF YOU"  << endl
   << "USED WILDCARDS, ALL FILES WITH NAMES MATCHING THE WILDCARDS) WILL HAVE THEIR"     << endl
   << "ORIGINAL NAMES OBLITERATED!!!  ARE YOU ABSOLUTELY SURE THAT THIS IS REALLY"       << endl
   << "WHAT YOU WANT TO DO???  THIS IS IRREVERSIBLE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"   << endl
                                                                                         << endl;
   return;
}
