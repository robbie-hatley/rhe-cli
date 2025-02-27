
/************************************************************************************************************\
 * File name:      dedup-files.cpp
 * Source for:     dedup-files.exe
 * Program Name:   DeDup Files
 * Description:    Alerts user to existence of duplicate files and prompts user to delete such files.
 * Author:         Robbie Hatley
 * Date written:   Thursday May 6, 2004
 * Inputs:         An optional command line argument, which must be one of these switches:
 *                 "-r" or "--recurse" to recurse subdirectories
 *                 "-h" or "--help" for help
 * Outputs:        Writes to stdout.  (Can be redirected to a file.)
 * Dependencies:
 *    rhutil.h, rhdir.h, librh.a, unistd.h (djgpp compiler-dependent header; see www.delorie.com).
 * To make:
 *    Compile with djgpp (see www.delorie.com) and link with rhutil.o and rhdir.o in library librh.a .
 * Edit history:
 *    Sat Jun 26, 2004
 *    Sun Jan 16, 2005 - Introduced -> notation.
 *    Mon Aug 22, 2005 - Dramatically simplified main(), and updated incredibly wrong instructions.
 *    Mon Sep 05, 2005 - Renamed program to "dedup-files".  Renamed function SortDup() to DupPrompt().
 *                       Got rid of conio.h and getch.  (Now using pc.h and getkey() instead.)
\************************************************************************************************************/

#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>
#include <list>
#include <string>
#include <map>

#include <cstdlib>
#include <cstring>
#include <cctype>

// I include the following non-std. headers to get certain needed functions:
#include <unistd.h>
#include <pc.h>
#include <keys.h>

// RH headers:
#include "rhdefines.h"
#include "rhutilc.h"
#include "rhutil.hpp"
#include "rhdir.hpp"
#include "rhregex.hpp"

namespace ns_rhdedup
{
   using std::cout;
   using std::cerr;
   using std::endl;
   using std::list;
   using std::string;
   using std::ostream;
   using std::ifstream;
   using std::left;
   using std::right;
   using std::setfill;
   using std::setw;

   typedef  std::list<std::string>     LS;
   typedef  LS::iterator               LSI;
   typedef  LS::const_iterator         LSCI;
   typedef  std::vector<std::string>   VS;
   typedef  VS::iterator               VSI;
   typedef  VS::const_iterator         VSCI;
   typedef  rhdir::FileRecord          FR;
   typedef  std::multimap<size_t, FR>  MMFR;
   typedef  MMFR::iterator             MMFRI;
   typedef  MMFR::const_iterator       MMFRCI;
   typedef  std::list<FR>              LF;
   typedef  LF::iterator               LFI;
   typedef  LF::const_iterator         LFCI;
   typedef  std::vector<FR>            VF;
   typedef  VF::iterator               VFI;
   typedef  VF::const_iterator         VFCI;

   struct Settings_t  // Program settings (boolean or otherwise).
   {
      bool bHelp;     // Did user ask for help?
      bool bRecurse;  // Walk directory tree downward from current node?
      bool bNoPrompt; // Perform all operations automatically without prompting?
   };

   void
   ProcessFlags       // Set settings based on flags.
   (
      VS          const  &  Flags,
      Settings_t         &  Settings
   );

   void
   ProcessArguments   // Set settings based on arguments.
   (
      VS          const  &  Arguments,
      Settings_t         &  Settings
   );

   struct Stats_t     // program run-time statistics
   {
      uint32_t  DirCount;  // How many directories did we process?
      uint32_t  FilCount;  // How many files did we process?
      uint32_t  DelCount;  // How many files did we delete?
      uint32_t  ErrCount;  // How many errors did we encounter?
      void PrintStats (void)
      {
         cout
                                                                   << endl
            << "Finished processing files in this tree."           << endl
            << "Directories processed:   " << setw(7) << DirCount  << endl
            << "Files examined:          " << setw(7) << FilCount  << endl
            << "Files deleted:           " << setw(7) << DelCount  << endl
            << "Errors encountered:      " << setw(7) << ErrCount  << endl
                                                                   << endl;
      }
   };

   class ProcessCurDirFunctor
   {
      public:
         ProcessCurDirFunctor
            (
               Settings_t         &  Settings_,
               VS          const  &  Arguments_,
               Stats_t            &  Stats_,
               MMFR               &  FileMultiMap_
            )
            : Settings(Settings_), Arguments(Arguments_), Stats(Stats_), FileMultiMap(FileMultiMap_)
            {}
         void operator()(void); // defined below
      private:
         Settings_t         &  Settings;
         VS          const  &  Arguments;
         Stats_t            &  Stats;
         MMFR               &  FileMultiMap;
   };

   // Function Prototypes:

   void DupPrompt  (Settings_t & Settings, MMFRI & i, MMFRI & j, Stats_t & Stats);
   void EraseNewer (MMFRI & i, MMFRI & j, Stats_t & Stats);
   void Help       (void);

} // End namespace ns_rhdedup



//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  main()                                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

int main (int Beren, char * Luthien[])
{
   // Set main namespace we're using:
   using namespace ns_rhdedup;

   // Make a "settings" object to hold program settings:
   Settings_t Settings = Settings_t();

   // Make a "flags" object to hold flags:
   VS Flags;

   // Get flags (items in Luthien starting with '-'):
   rhutil::GetFlags (Beren, Luthien, Flags);
   
   // Process flags (set settings based on flags):
   ProcessFlags(Flags, Settings);

   // If user wants help, just print help and return:
   if (Settings.bHelp)
   {
      Help();
      return 777;
   }

   // Make an "arguments" object to hold arguments:
   VS Arguments;

   // Get arguments (items in Luthien *not* starting with '-'):
   rhutil::GetArguments(Beren, Luthien, Arguments);

   // Process arguments (set settings based on arguments; this can be deleted if not using
   // arguments to set settings):
   ProcessArguments(Arguments, Settings);

   // Make a stats object to hold program run-time statistics:
   Stats_t Stats = Stats_t();

   // Make a multipap of file records (in "static" memory instead of the stack, else this can very easily
   // overflow the stack!!!):
   static MMFR FileMultiMap;

   // Create a function object of type "ProcessCurDirFunctor" for use with CursDirs:
   ProcessCurDirFunctor ProcessCurDir (Settings, Arguments, Stats, FileMultiMap);

   // If recursing, pass ProcessCurDir to CursDirs:
   if (Settings.bRecurse)
   {
      rhdir::CursDirs(ProcessCurDir);
   }

   // Otherwise, just run ProcessCurDir():
   else
   {
      ProcessCurDir();
   }

   // Processing files is finished, so print final stats:
   Stats.PrintStats();

   // We be done, so scram:
   return 0;
} // end main()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessFlags()                                                          //
//                                                                          //
//  Sets program settings based on Flags.                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_rhdedup::
ProcessFlags
   (
      VS          const  &  Flags,
      Settings_t         &  Settings
   )
{
   BLAT("\nJust entered ProcessFlags().  About to set settings.\n")

   // Use InVec from rhutil:
   using rhutil::InVec;

   Settings.bHelp     = InVec(Flags, "-h") or InVec(Flags, "--help"    );
   Settings.bRecurse  = InVec(Flags, "-r") or InVec(Flags, "--recurse" );
   Settings.bNoPrompt = InVec(Flags, "-y") or InVec(Flags, "--noprompt");

   BLAT("About to return from ProcessFlags.\n")
   return;
} // end ns_rhdedup::ProcessFlags()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessArguments()                                                      //
//                                                                          //
//  Sets program settings based on Arguments.                               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_rhdedup::
ProcessArguments
   (
      VS          const  &  Arguments,
      Settings_t         &  Settings
   )
{
   BLAT("\nJust entered ProcessArguments().\n")

   // Insert commands here to set settings based on arguments.
   // Or, if this program isn't going to do that, just erase this whole damn function.

   BLAT("About to return from ProcessArguments.\n")
   return;
} // end ns_rhdedup::ProcessArguments()


/************************************************************************************************************\
 * ProcessCurDirFunctor::operator()                                                                         *
 * Processes the current directory:                                                                         *
 * 1. Sorts files into candidates and non-candidates.                                                       *
 * 2. Simplifies names of matchless candidates.                                                             *
 * 3. Demotes matchless candidates back to non-candidates.                                                  *
 * 4. Erases duplicates.                                                                                    *
\************************************************************************************************************/
void ns_rhdedup::ProcessCurDirFunctor::operator() (void)
{
   // Make a bool var to indicate duplicates:
   bool bDuplicate = false;

   // Get non-const iterators to the elements of FileMap:
   MMFRI i, j, Next;

   // Increment directory counter:
   ++Stats.DirCount;

   // Annouce processing current directory:
   cout << "Now processing directory #" << Stats.DirCount << ":" << endl;
   cout << rhdir::GetFullCurrPath() << endl;

   // Convert any tilde ('~') characters in file names in current directory to underscore ('_') characters:
   rhdir::UnTilde();

   // Load sizes and file records of all files in current directory into a multimap<size_t, FileRecord>,
   // so that the files are sorted and grouped in order of increasing size:
   rhdir::LoadFileMap(FileMultiMap, "*", 1);

   // NOTE: At all times, FileMultiMap contains all data on all files which *WERE* in the current directory 
   // at the instant this instance of ProcessCurDirFunctor::operator() was invoked.  However, since the
   // whole point of this program and this function is to erase unwanted files, as execution of this function
   // continues, some of the files recorded in FileMultiMap may no longer physically exist.  Each file which
   // no longer exists due to deletion will have its name changed to "/* DELETED */" at time of deletion.

   // Start with Next pointing to the first element of the multimap:
   Next = FileMultiMap.begin();

   // For each file in FileMultiMap:
   for ( i = FileMultiMap.begin() ; i != FileMultiMap.end() ; ++i )
   {
      // Increment count of files processed:
      ++Stats.FilCount;

      // NOTE: Don't test for i being deleted at this point, because i may get deleted after our test
      // but before sending i and j to rhdir::FilesAreIdentical().  Instead, test i and j in inner
      // for loop, immediately before invoking rhdir::FilesAreIdentical().

      // If i points to the first element of a size group, point Next to first element of next group:
      // (Note: first time through this loop, i and Next are both equal to FileMultiMap.begin().)
      if (i == Next)
      {
         Next = FileMultiMap.upper_bound (i->first);
      }

      // For each file in this size group after i but before next group:
      for ( j = i, ++j; j != Next ; ++j )
      {
         // Break to next i if current i has been deleted:
         if ("/* DELETED */" == i->second.name)
         {
            break;
         }

         // Continue to next j if current j has been deleted:
         if ("/* DELETED */" == j->second.name)
         {
            continue;
         }

         // Try to determine if i and j are duplicates.  (Note that this is the first operation in this
         // function which actually involves opening any files.  Hence here we have the possibility of
         // file IO failure.  To avoid having the program crash -- or worse, damaging directory 
         // structures or file data -- we use C++'s "try / throw / catch" exception-handling mechanism.)
         try
         {
            bDuplicate = rhdir::FilesAreIdentical(i->second.name, j->second.name);
         }

         // If rhdir::FilesAreIdentical throws Up, catch the vomit here, print message, and 
         // continue to next j:
         catch (rhdir::FileIOException Up)
         {
            // Increment error counter:
            ++Stats.ErrCount;
            // Print error message:
            cerr 
               << "Error in dedup-files.exe: while comparing two files, rhdir::FilesAreIdentical()" << endl
               << "threw Up.  Embedded message in rhdir::FileIOException object Up is as follows:"  << endl
               << Up.msg                                                                            << endl
               << "Continuing with next file."                                                      << endl;
            continue;
         }

         // If files are identical, send i and j to DupPrompt, which will either prompt user with options,
         // or erase newer duplicate without prompting, depending on Settings.bNoPrompt:
         if (bDuplicate)
         {
            DupPrompt(Settings, i, j, Stats);
         }

      } // End for each j

   } // End for each i

   return;

} // End ns_rhdedup::ProcessCurDirFunctor::operator()



/************************************************************************************************************\
 * DupPrompt()                                                                                              *
 * Prompts user regarding duplicate files found in ProcessCurrentDirectory().  Gives user these choices:    *
 * 1. Erase the first  duplicate.                                                                           *
 * 2. Erase the second duplicate.                                                                           *
 * 3. Ignore these duplicates and move on to the next.                                                      *
 * 4. Exit the program.                                                                                     *
 * 5. Erase all newer duplicates.                                                                           *
\************************************************************************************************************/

void
ns_rhdedup::
DupPrompt
   (
      Settings_t  &  Settings,
      MMFRI       &  i,
      MMFRI       &  j,
      Stats_t     &  Stats
   )
{
   // If in "delete without prompting" mode, delete newer file without prompting.
   // (We delete newer instead of older, so that date indicates time-of-origin of
   // this version of this file.)
   if (Settings.bNoPrompt)
   {
      ns_rhdedup::EraseNewer(i, j, Stats);
      return;
   }
   else
   {
      cout << "\n\nThese two files are duplicates:" << endl;
      cout << i->second << endl;
      cout << j->second << endl;
      cout << "Press 1 to delete " << (i->second.name) << "." << endl;
      cout << "Press 2 to delete " << (j->second.name) << "." << endl;
      cout << "Press 3 to ignore these duplicates." << endl;
      cout << "Press 4 to abort program." << endl;
      cout << "Press 5 to delete all newer duplicates without prompting." << endl;
      char ch = '\0';
      while (42)
      {
         ch = getkey();
         switch (ch)
         {
            case '1':
               ++Stats.DelCount;
               remove(i->second.name.c_str());
               cout << "Erased file " << i->second.name << endl;
               i->second.name = string ("/* DELETED */");
               return;
            case '2':
               ++Stats.DelCount;
               remove(j->second.name.c_str());
               cout << "Erased file " << j->second.name << endl;
               j->second.name = string ("/* DELETED */");
               return;
            case '3':
               return;
            case '4':
               exit(-8474);
            case '5':
               Settings.bNoPrompt = true;
               ns_rhdedup::EraseNewer(i, j, Stats);
               return;
         }
      }
   }
} // End ns_rhdedup::DupPrompt().



/************************************************************************************************************\
 * EraseNewer()                                                                                             *
 * Given iterators to two duplicate files, erases the newer of the two.                                     *
\************************************************************************************************************/

void
ns_rhdedup::
EraseNewer
   (
      MMFRI    &  i,
      MMFRI    &  j,
      Stats_t  &  Stats
   )
{
   // If file i is newer than file j, erase it:
   if (i->second.timestamp > j->second.timestamp)
   {
      remove(i->second.name.c_str());
      cout << "Erased file " << i->second.name << endl;
      i->second.name = std::string ("/* DELETED */");
   }

   // Otherwise, erase file j instead:
   else
   {
      remove(j->second.name.c_str());
      cout << "Erased file " << j->second.name << endl;
      j->second.name = std::string ("/* DELETED */");
   }

   // Increment file deletion count:
   ++Stats.DelCount;

   // We do be done, so scram:
   return;
} // End ns_rhdedup::EraseNewer().



/************************************************************************************************************\
 * Help()                                                                                                   *
 * Print help.                                                                                              *
\************************************************************************************************************/
void ns_rhdedup::Help(void)
{
   cout
   << "Welcome to dedup-files.exe, Robbie Hatley's duplicate file remover."             << endl
   << "This version was compiled at " << __TIME__ << " on " << __DATE__ << "."          << endl
                                                                                        << endl
   << "dedup-files.exe finds all duplicated files in the current directory.  For"       << endl
   << "each pair of duplicate files, it gives the user the choice of deleting the"      << endl
   << "first file, deleting the second file, ignoring the duplicates, deleting all"     << endl
   << "newer duplicates automatically, or aborting the program."                        << endl
                                                                                        << endl
   << "Use an -r or --recurse  switch to process all subdirectories."                   << endl
   << "Use an -h or --help     switch to display help and exit."                        << endl
   << "Use an -y or --noprompt switch to erase all newer duplicates without prompting." << endl;
   return;
} // End ns_rhdedup::Help(void).
