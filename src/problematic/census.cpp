
/****************************************************************************\
 * Program name:  (this line for stand-alone programs only)
 * File name:
 * Source for:    (this line for source files only)
 * Description:   Displays the number of files in the current directory,
 *                and in all its subdirectories if recursing.
 * Author:        Robbie Hatley
 * Date written:  Tue Mar 24, 2009
 * Inputs:
 * Outputs:
 * Notes:
 * To make:
 * Edit History:
 *   Tue Mar 24, 2009 - Wrote it.
 *   Mon Mar 30, 2009 - Added help, comments, these notes, etc.
 *   Sat Aug 06, 2011 - Added --empty switch to show empty directories only.
 *                      Also added "EmpCount" to tally empty directories.
\****************************************************************************/

#include <ctime>

#include <iostream>
#include <iomanip>
#include <fstream>
#include <vector>
#include <list>
#include <string>

// Use assert?  (Undefine "NDEBUG" to use asserts; define it to NOT use them.)
#define NDEBUG
#undef  NDEBUG
#include <assert.h>
#include <errno.h>

// Use BLAT?  (Define "BLAT_ENABLE" to use BLAT; undefine it to NOT use BLAT.)
#define BLAT_ENABLE
#undef  BLAT_ENABLE

#include "rhutil.hpp"
#include "rhdir.hpp"

namespace ns_Census
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

   struct Settings_t
   {
      bool      bHelp;     // Did user ask for help?
      bool      bRecurse;  // Walk directory tree downward from current node?
      bool      bEmpty;    // Show only empty directories?
      uint32_t  AtLeast;   // Show only directories with at least AtLeast files?
   };

   void
   ProcessFlags
   (
      VS           const  &  Flags,
      Settings_t          &  Settings
   );

   void
   ProcessArguments
   (
      VS           const  &  Arguments,
      Settings_t          &  Settings
   );

   struct Stats_t     // program run-time statistics
   {
      uint32_t  DirCount;  // How many directories did we process?
      uint32_t  EmpCount;  // How many empty directories did we find?
      uint32_t  FilCount;  // How many files did they contain?
      void PrintStats (void)
      {
         cout
            << "\n"
            << "Processed " << DirCount << " directories.\n"
            << "Found " << EmpCount << " empty directories.\n"
            << "Tree contains " << FilCount << " files." << endl;
      }
   };

   class ProcessCurDirFunctor
   {
      public:
         ProcessCurDirFunctor
            (
               Settings_t  const  &  Settings_,
               Stats_t            &  Stats_,
               VF                 &  FileList_
            )
            : Settings(Settings_), Stats(Stats_), FileList(FileList_)
            {}
         void operator()(void); // defined below
      private:
         Settings_t  const  &  Settings;
         Stats_t            &  Stats;
         VF                 &  FileList;
   };

   void Help (void);
}


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  main()                                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

int main (int Beren, char * Luthien[])
{
   using namespace ns_Census;
   VS Flags;
   rhutil::GetFlags (Beren, Luthien, Flags);

   Settings_t Settings = Settings_t();
   ProcessFlags(Flags, Settings);

   if (Settings.bHelp)
   {
      Help();
      return 777;
   }

   VS Arguments;
   rhutil::GetArguments(Beren, Luthien, Arguments);
   ProcessArguments(Arguments, Settings);

   Stats_t Stats = Stats_t();
   static VF FileList;
   FileList.reserve(10000);
   ProcessCurDirFunctor ProcessCurDir (Settings, Stats, FileList);

   if (Settings.bRecurse)
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
ns_Census::
ProcessFlags
   (
      VS       const  &  Flags,
      Settings_t         &  Settings
   )
{
   BLAT("\nJust entered ProcessFlags().  About to set Settings.\n")

   // Use InVec from rhutil:
   using rhutil::InVec;

   Settings.bHelp    =   InVec(Flags, "-h") or InVec(Flags, "--help"     ) ;
   Settings.bRecurse = !(InVec(Flags, "-n") or InVec(Flags, "--norecurse"));
   Settings.bEmpty   =   InVec(Flags, "-e") or InVec(Flags, "--empty"    ) ;

   BLAT("About to return from ProcessFlags.\n")
   return;
} // end ns_Census::ProcessFlags()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessArguments()                                                      //
//                                                                          //
//  Sets program settings based on arguments.                               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_Census::
ProcessArguments
   (
      VS          const  &  Arguments,
      Settings_t         &  Settings
   )
{
   BLAT("\nJust entered ProcessArguments().  About to set Settings.\n")

   // If number of arguments is greater than zero, interpret first argument as 
   // "show only directories with at least this number of files", and ignore
   // all other arguments:
   if (Arguments.size() > 0)
   {
      Settings.AtLeast = static_cast<uint32_t>(atoi(Arguments[0].c_str()));
   }

   // Otherwise, set Settings.AtLeast to zero, so we show all directories:
   else
   {
      Settings.AtLeast = 0;
   }

   BLAT("About to return from ProcessFlags.\n")
   return;
} // end ns_Census::ProcessFlags()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurDirFunctor::operator()                                        //
//                                                                          //
//  Processes current directory.                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void ns_Census::ProcessCurDirFunctor::operator() (void)
{
   BLAT("\nJust entered ProcessCurDir::operator().\n")

   // ABSTRACT:
   // The idea of this function is to display the populations of the
   // current directory, and all its subdirectories if recursing.


   // ============= GET FILE DATA: =============

   // Get current directory:
   std::string CurDir = rhdir::GetFullCurrPath();

   // Get list of FileRecords for all files (but not dirs)
   // in current directory:
   FileList.clear();
   rhdir::LoadFileList(FileList);
   uint32_t NumFiles = FileList.size();


   // ============= UPDATE PROGRAM STATS: =============

   // Increment directory counter:
   ++Stats.DirCount;

   // If current directory is empty, increment Stats.EmpCount:
   if (0 == NumFiles)
   {
      ++Stats.EmpCount;
   }

   // Otherwise, add the size of the current directory to Stats.FilCount:
   else
   {
      Stats.FilCount += NumFiles;
   }


   // ============= PRINT CENSUS INFO: =============

   // If showing only empty dirs, and curr dir isn't empty, do nothing:
   if (Settings.bEmpty and NumFiles > 0)
   {
      ; // Do nothing.
   }

   // Else if number of files is less than Settings.AtLeast, do nothing;
   else if (NumFiles < Settings.AtLeast)
   {
      ; // Do nothing.
   }

   // Otherwise, print census info for current directory:
   else
   {
      cout << std::setw(5) << FileList.size() << "  " << CurDir << endl;
   }

   BLAT("\nAbout to return from ProcessCurDir::operator().\n")

   return;
} // end ns_Census::ProcessCurDirFunctor::operator()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Help()                                                                  //
//                                                                          //
//  Prints help.                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_Census::
Help
   (
      void
   )
{
   //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
   cout
                                                                                               << endl
   << "Welcome to Census, Robbie Hatley's file-tree census utility."                           << endl
                                                                                               << endl
   << "This version compiled at " << __TIME__ << " on " << __DATE__ << "."                     << endl
                                                                                               << endl
   << "Command-line syntax:"                                                                   << endl
   << "census [switches] [argument]"                                                           << endl
                                                                                               << endl
   << "Switch:               Meaning:"                                                         << endl
   << "\"-h\" or \"--help\"        Print help and exit."                                       << endl
   << "\"-n\" or \"--norecurse\"   Process current directory only."                            << endl
   << "\"-e\" or \"--empty\"       Show empty directories only."                               << endl
                                                                                               << endl
   << "Census announces the count of files (not counting directories) in the current"          << endl
   << "directory, and in each of its subdirectories, and in the entire tree.  Or, if"          << endl
   << "a \"-n\" or \"-norecurse\" switch is used, Census counts files in the current"          << endl
   << "directory only.  If a \"-e\" or \"--empty\" switch is used, Census will show"           << endl
   << "only empty directories (those with file count 0)."                                      << endl
                                                                                               << endl
   << "If an argument is used, it is treated as an integer (if it's non-numeric, it"           << endl
   << "will be considered to be 0), and only directories containing at least that"             << endl
   << "number of files will be listed (though the contents of the other directories"           << endl
   << "will still be included in the total file count for the tree).  All arguments"           << endl
   << "after the first argument (if any) will be ignored."                                     << endl
                                                                                               << endl;

   return;
}

// end file MyFancyProgram.cpp
