#undef DEBUG_ENUMERATE
/************************************************************************************************************\
 * File name:       enumerate-file-names.cpp
 * Source for:      enumerate-file-names.exe
 * Program name:    Enumerate File Names
 * Author:          Robbie Hatley
 * Date written:    Thu. Jun. 2, 2005
 *
 * Notes:
 *    This program tacks a numerator (a hyphen, followed by a random 4-digit number in parentheses), to the
 *    ends of the prefixes of all the file names in the current directory (and all its subdirectories, if
 *    the "-r" or "--recurse" switch is used).  It also changes any mulitple numerators to single numerators.
 *
 * Edit history:
 *    Mon Aug 08, 2005 - Added demuliplication of numerators.
 *    Mon Oct 10, 2005 - Added ability to enumerate only those files matching one or more wildcards.
 *    Fri Nov 09, 2007 - Fixed "runs after help" bug.  Fixed "passes -r as wildcard" bug.
 *
 * To make:         Link with modules rhutil.o and rhdir.o in librh.a
\************************************************************************************************************/

#include <cstdlib>
#include <ctime>

#include <iostream>
#include <iomanip>
#include <vector>
#include <list>
#include <string>

// To use asserts, undef NDEBUG.
// To NOT use asserts, define NDEBUG.
#define NDEBUG
#undef  NDEBUG
#include <assert.h>
#include <errno.h>

// To use BLAT, define BLAT_ENABLE.
// To NOT use BLAT, undef BLAT_ENABLE.
#define BLAT_ENABLE
#undef  BLAT_ENABLE

#include "rhutil.hpp"
#include "rhdir.hpp"

namespace ns_EFN
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
   typedef  std::list<FR>             LFR;
   typedef  LFR::iterator             LFRI;
   typedef  LFR::const_iterator       LFRCI;
   typedef  std::vector<FR>           VFR;
   typedef  VFR::iterator             VFRI;
   typedef  VFR::const_iterator       VFRCI;

   struct Bools_t     // program boolean settings
   {
      bool bHelp;     // Did user ask for help?
      bool bRecurse;  // Walk directory tree downward from current node?
   };

   struct Stats_t     // program run-time statistics
   {
      uint32_t  DirCount;  // Count of directories processed.
      uint32_t  FilCount;  // Count of files examined.
      uint32_t  ErrCount;  // Count of errors encountered.
      uint32_t  EnuCount;  // Count of file names successfully enumerated.
      void PrintStats (void)
      {
         cout
                                                                 << endl
            << "Finished enumerating file names in this tree."   << endl
            << "Directories processed: " << setw(7) << DirCount  << endl
            << "Files examined:        " << setw(7) << FilCount  << endl
            << "Errors encountered:    " << setw(7) << ErrCount  << endl
            << "File names enumerated: " << setw(7) << EnuCount  << endl
                                                                 << endl;
      }
   };

   void
   ProcessFlags
   (
      VS           const  &  Flags,
      Bools_t             &  Bools
   );

   class ProcessCurDirFunctor
   {
      public:
         ProcessCurDirFunctor
            (
               Bools_t  const  &  Bools_,
               VS       const  &  Arguments_,
               Stats_t         &  Stats_,
               VFR             &  FileList_
            )
            : Bools(Bools_), Arguments(Arguments_), Stats(Stats_), FileList(FileList_)
            {}
         void operator()(void); // defined below
      private:
         Bools_t  const  &  Bools;
         VS       const  &  Arguments;
         Stats_t         &  Stats;
         VFR             &  FileList;
   };

   void
   ProcessCurrentFile
   (
      Stats_t         &  Stats,
      FR       const  &  FileRec
   );

   void Help (void);

}


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  main()                                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

int main (int Beren, char * Luthien[])
{
   using namespace ns_EFN;
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
   static VFR FileList;
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
ns_EFN::
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
} // end ns_EFN::ProcessFlags()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurDirFunctor::operator()                                        //
//                                                                          //
//  Processes current directory.                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void ns_EFN::ProcessCurDirFunctor::operator() (void)
{
   // ABSTRACT:
   // This function adds numerators (such as "-(3956)") to the names of
   // all of the files in the current directory (and all its subdirectories,
   // if recursing).

   BLAT("\nJust entered ProcessCurDir::operator().\n")

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

   // Process all files in list:
   for ( VFRCI i = FileList.begin() ; i != FileList.end() ; ++i )
   {
      ++Stats.FilCount;
      ProcessCurrentFile(Stats, *i);
   } // End for (each file in FileList)

   BLAT("\nAt bottom of ProcessCurDirFunctor::operator(); about to return.\n")
   return;
} // end ns_EFN::ProcessCurDirFunctor::operator()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurrentFile()                                                    //
//                                                                          //
//  Processes current file.                                                 //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_EFN::
ProcessCurrentFile
   (
      Stats_t         &  Stats,
      FR       const  &  FileRec
   )
{
   // ABSTRACT:
   // Enumerates name of current file.
   // 
   // 

   BLAT("\nJust entered ProcessCurrentFile().")
   BLAT("About to get OldFileName.\n")

   // Grab old file name:
   std::string OldFileName = FileRec.name;

   BLAT("\nIn ProcessCurrentFile(); finished getting OldFileName;")
   BLAT("about to run Debracket().\n")

   // Debracket the file name:
   std::string DebracketedFileName = rhdir::Debracket(OldFileName);

   BLAT("\nIn ProcessCurrentFile(); finished debracketing old file name;")
   BLAT("about to attempt to find an unused new file name.\n")

   // Try at most 25 times to find an unused new file name:
   std::string NewFileName;
   bool bSuccess = false;
   int Trial = 0;
   for (Trial=1; Trial<=25; ++Trial)
   {
      NewFileName = rhdir::Enumerate(DebracketedFileName);
      bSuccess = !__file_exists(NewFileName.c_str());
      if (bSuccess) break;
   }

   if (bSuccess && Trial > 5)
   {
      cerr
                                                                                       << endl
      << "Warning from enumerate-file-names: it took " << Trial << " attempts to find" << endl
      << "an unused new name for this file:"                                           << endl
      << "Old file name: " << OldFileName                                              << endl
      << "New file name: " << NewFileName                                              << endl;
   }

   if (!bSuccess)
   {
      cerr
                                                                                       << endl
      << "Error in ProcessCurrentFile() in enumerate-file-names.exe:"                  << endl
      << "unable to create an unused new file name for this file:"                     << endl
      << OldFileName                                                                   << endl
      << "even after 25 attempts.  Bypassing this file and Moving on to next file."    << endl;
      ++Stats.ErrCount;
      return; // Move on to next file.
   }

   BLAT("\nIn ProcessCurrentFile(); finished getting new file name;")
   BLAT("about to attempt file rename.")
   BLAT("Old name = " << OldFileName)
   BLAT("New name = " << NewFileName << "\n")

   std::cout << OldFileName << " -> " << NewFileName << std::endl;

   bSuccess = rhdir::RenameFile(OldFileName, NewFileName);
   if (bSuccess)
   {
      ++Stats.EnuCount;
   }
   else
   {
      ++Stats.ErrCount;
      cerr
                                                                              << endl
         << "Error in ProcessCurrentFile() in  enumerate-file-names.exe:"     << endl
         << "The following file rename failed:"                               << endl
         << "Old file name:  " << OldFileName                                 << endl
         << "New file name:  " << NewFileName                                 << endl
         << "Continuing with next file."                                      << endl
                                                                              << endl;

   }

   BLAT("\nAt end of ProcessCurrentFile(); about to return.\n")
   return;
} // end ns_EFN::ProcessCurrentFile()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Help()                                                                  //
//                                                                          //
//  Prints help.                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_EFN::
Help
   (
      void
   )
{
   cout << "Welcome to Robbie Hatley's file name enumerating and renaming program,"           << endl;
   cout << "enumerate-file-names.exe (hereafter referred to as \"efn\")."                     << endl;
   cout                                                                                       << endl;
   cout << "This version compiled at " << __TIME__ << " on " << __DATE__ << "."               << endl;
   cout                                                                                       << endl;
   cout << "Usage:"                                                                           << endl;
   cout << "   enumerate-file-names -h | --help"                                              << endl;
   cout << "   enumerate-file-names [-r | --recurse] [wildcard]..."                           << endl;
   cout                                                                                       << endl;
   cout << "Efn renames any files in the current directory (and all its"                      << endl;
   cout << "subdirectories if an \"-r\" or \"--recurse\" switch is used) which match the"     << endl;
   cout << "the wildcards given as arguments.  If no wildcards are given, efn renames all"    << endl;
   cout << "files.  Efn makes the following alterations to the name of each file it"          << endl;
   cout << "renames:"                                                                         << endl;
   cout << "1. Removes any instances of \"[#]\" substrings."                                  << endl;
   cout << "2. Removes any instances of \"-(####)\" substrings."                              << endl;
   cout << "3. Tacks a \"numerator\" (a \"-(####)\" substring, where the \"####\" is a "      << endl;
   cout << "   random number) to the end of the prefix."                                      << endl;
   cout << "If a file already exists with the proposed new file name, efn tries various"      << endl;
   cout << "random numerators until the rename is successful."                                << endl;
   cout                                                                                       << endl;
   cout << "This program is especially useful preparatory to consolidating files from"        << endl;
   cout << "multiple directories.  Recommended procedure:"                                    << endl;
   cout << "1. Use enumerate-file-names.exe to add numerators to the names of all the files"  << endl;
   cout << "   in each source directory."                                                     << endl;
   cout << "2. Move files from multiple source directories to a consolidation directory."     << endl;
   cout << "3. Run dedup-newsbin-files.exe to remove duplicate files."                        << endl;
   cout << "4. Run denumerate-file-names.exe to strip-off the left-over numerators from the"  << endl;
   cout << "   file names."                                                                   << endl;
   return;
} // end ns_EFN::Help()

// end file enumerate-file-names.cpp
