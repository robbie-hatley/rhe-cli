

/************************************************************************************************************\
 * Program name:    UnTilde
 * File name:       untilde.cpp
 * Author:          Robbie Hatley
 * Date written:    Saturday April 24, 2004
 * Description:     Changes tildes to underscores in all filenames in current directory
 * To make:         Link with rhutil.o and rhdir.o in librh.a
 * Edit history:
 *    Sat. Jun. 26, 2004
 *    Sun. Jan. 16, 2005 - changed parameter names to something more interesting.
\************************************************************************************************************/

#include <ctime>

#include <iostream>
#include <iomanip>
#include <vector>
#include <list>
#include <string>

#include <cstdlib>

// To use asserts, undef NDEBUG.
// To NOT use asserts, define NDEBUG.
#define NDEBUG
#undef  NDEBUG
#include <assert.h>
#include <errno.h>

// To use BLAT, define BLAT_ENABLE.
// To NOT use BLAT, undef BLAT_ENABLE.
#undef  BLAT_ENABLE
#define BLAT_ENABLE

#include "rhutil.hpp"
#include "rhdir.hpp"

namespace ns_UNT
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
      bool bVerbose;  // Drive user crazy with bloated verbiage?
   };

   struct Stats_t     // program run-time statistics
   {
      uint32_t  DirCount;  // Count of directories processed.
      uint32_t  FilCount;  // Count of files examined.
      uint32_t  ErrCount;  // Count of errors encountered.
      uint32_t  UntCount;  // Count of file names successfully untildeed.
      void PrintStats (void)
      {
         cout
                                                                 << endl
            << "Finished enumerating file names in this tree."   << endl
            << "Directories processed: " << setw(7) << DirCount  << endl
            << "Files examined:        " << setw(7) << FilCount  << endl
            << "Errors encountered:    " << setw(7) << ErrCount  << endl
            << "File names untildeed:  " << setw(7) << UntCount  << endl
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
   using namespace ns_UNT;
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
ns_UNT::
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
   Bools.bVerbose = InVec(Flags, "-v") or InVec(Flags, "--verbose");

   BLAT("About to return from ProcessFlags.\n")
   return;
} // end ns_UNT::ProcessFlags()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurDirFunctor::operator()                                        //
//                                                                          //
//  Processes current directory.                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void ns_UNT::ProcessCurDirFunctor::operator() (void)
{
   // ABSTRACT:
   // For each file in current directory, calls ProcessCurrentFile(),
   // which which converts all "~" characters to "_" characters in the file name.
   

   BLAT("\nJust entered ProcessCurDir::operator().\n")

   // Increment directory counter:
   ++Stats.DirCount;

   // Get current directory:
   std::string CurDir = rhdir::GetFullCurrPath();

   // If being verbose, announce processing current directory:
   if (Bools.bVerbose)
   {
      cout
         << "\n"
         << "=================================================================\n"
         << "Directory #" << Stats.DirCount << ":\n"
         << CurDir << "\n"
         << endl;
   }

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
} // end ns_UNT::ProcessCurDirFunctor::operator()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurrentFile()                                                    //
//                                                                          //
//  Processes current file.                                                 //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_UNT::
ProcessCurrentFile
   (
      Stats_t         &  Stats,
      FR       const  &  FileRec
   )
{
   // ABSTRACT:
   // Changes all "~" to "_" in name of current file.
   // 
   // 

   BLAT("\nJust entered ProcessCurrentFile().")
   BLAT("About to get old and new file names.\n")

   bool                       bSucceed   = false;
   std::string                OldName    = std::string();
   std::string                NewName    = std::string();
   std::string::size_type     Tilde      = 0;

   OldName = FileRec.name;
   NewName = OldName;

   while (std::string::npos != (Tilde = NewName.find('~')))
   {
      NewName.replace(Tilde, 1, 1, '_');
   }

   BLAT("\nIn ProcessCurrentFile().  Finished getting old and new file names.\n")

   if (NewName != OldName)
   {
      BLAT("\nIn ProcessCurrentFile().")
      BLAT("About to attempt to the following file rename:")
      BLAT("Old name: " << OldName)
      BLAT("New name: " << NewName << "\n")
      bSucceed = rhdir::RenameFile(OldName, NewName);
      if (bSucceed)
      {
         BLAT("\nIn ProcessCurrentFile().  File rename succeeded.\n")
         ++Stats.UntCount;
         cout << OldName << " -> " << NewName << " succeeded" << endl;
      }
      else
      {
         BLAT("\nIn ProcessCurrentFile().  File rename failed.\n")
         ++Stats.ErrCount;
         cerr
                                                                                          << endl
         << "Error in ProcessCurrentFile() in untilde.exe:"                               << endl
         << "rhdir::RenameFile() was unable to perform the following file rename:"        << endl
         << OldName << " -> " << NewName                                                  << endl
         << "Bypassing this file and Moving on to next file."                             << endl;
         return; // Move on to next file.
      }
   }

   BLAT("\nAt end of ProcessCurrentFile(); about to return.\n")
   return;
} // end ns_UNT::ProcessCurrentFile()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Help()                                                                  //
//                                                                          //
//  Prints help.                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_UNT::
Help
   (
      void
   )
{
   cout
                                                                                          << endl
   << "Converts tildes to underscores in file names.  Operates on contents of current"    << endl
   << "directory only, unless -r or --recurse flag is used, in which case operates on"    << endl
   << "contents of all subdirectories as well."                                           << endl
                                                                                          << endl;
   return;
} // end ns_UNT::Help()
