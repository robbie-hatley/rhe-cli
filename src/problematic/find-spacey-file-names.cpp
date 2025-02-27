
/************************************************************************************************************\
 * Program name:  Find Spacey File Names
 * Description:   Finds any files in the current directory (and all its subdirectories if an "-r" or
 *                "--recurse" switch is used) which have names which contain embedded spaces.
 *                It's probably a good idea to run program "find-bad-file-names.exe" before running this one.
 * File name:     find-spacey-file-names.cpp
 * Source for:    find-spacey-file-names.exe
 * Author:        Robbie Hatley
 * Date written:  Sun Dec 19, 2010
 * Actions:       Displays list of any files with names with embedded spaces.
 * Inputs:        Command-line switches and arguments.
 * Outputs:       Prints paths of all files with spacey names to stdout.
 * To make:       Link with modules rhutil.o and rudir.o in library librh.a
 * Edit History:
 *    Sun Dec 19, 2010 - Wrote it, based heavily on "find-bad-file-names.cpp".
\************************************************************************************************************/

#include <iostream>
#include <iomanip>
#include <string>
#include <list>
#include <vector>

// Include this non-std header to get "__file_exists()":
#include <unistd.h>

// Use assert?  (Undefine "NDEBUG" to use asserts; define it to NOT use them.)
//#define NDEBUG
#undef  NDEBUG
#include <assert.h>
#include <errno.h>

// Use BLAT?  (Define "BLAT_ENABLE" to use BLAT; undefine it to NOT use BLAT.)
#define BLAT_ENABLE
#undef  BLAT_ENABLE

#include "rhutil.hpp"
#include "rhdir.hpp"

namespace ns_FindSpaceyFileNames
{
   using std::cin;
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

   struct Settings_t  // Program settings (boolean or otherwise).
   {
      bool          bHelp;     // Did user ask for help?
      bool          bRecurse;  // Walk directory tree downward from current node?
      bool          bVerbose;  // Be verbose?
      int           ItemsNum;  // Files, directories, or both?  (1=files, 2=dirs, 3=both)
      std::string   ItemsStr;  // Files, directories, or both?  (text string)
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
      uint32_t  DirCount;  // Count of directories processed.
      uint32_t  FilCount;  // Count of files examined.
      uint32_t  SpcCount;  // Count of spacey file names found.
      uint32_t  ErrCount;  // Count of errors encountered.
      void PrintStats (void)
      {
         cout
                                                                        << endl
            << "Finished processing files in this tree."                << endl
            << "Directories processed:        " << setw(7) << DirCount  << endl
            << "Files examined:               " << setw(7) << FilCount  << endl
            << "Spacey file names found:      " << setw(7) << SpcCount  << endl
            << "Errors encountered:           " << setw(7) << ErrCount  << endl
                                                                        << endl;
      }
   };

   class ProcessCurDirFunctor
   {
      public:
         ProcessCurDirFunctor
            (
               Settings_t  const  &  Settings_,
               VS          const  &  Arguments_,
               Stats_t            &  Stats_,
               VFR                &  FileList_
            )
            : Settings(Settings_), Arguments(Arguments_), Stats(Stats_), FileList(FileList_)
            {}
         void operator()(void); // defined below
      private:
         Settings_t  const  &  Settings;
         VS          const  &  Arguments;
         Stats_t            &  Stats;
         VFR                &  FileList;
   };

   void
   ProcessCurrentFile
   (
      Settings_t  const  &  Settings,
      VS          const  &  Arguments,
      Stats_t            &  Stats,
      FR          const  &  FileRecord
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
   // Set main namespace we're using:
   using namespace ns_FindSpaceyFileNames;

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

   // Process arguments (set settings based on arguments):
   ProcessArguments(Arguments, Settings);

   // Make a stats object to hold program run-time statistics:
   Stats_t Stats = Stats_t();

   // Make a vector of file records:
   static VFR FileList;

   // Reserve room for info on 10,000 files (this Allocates memory for 10,000 items, but it doesn't
   // actually bloat the vector to that size yet; it just creates contiguous block of 10,000 cells
   // of "reserved-but-unused" space, so that we don't have to keep re-allocating as the vector grows):
   FileList.reserve(10000);

   // Create a function object of type "ProcessCurDirFunctor" for use with CursDirs:
   ProcessCurDirFunctor ProcessCurDir (Settings, Arguments, Stats, FileList);

   BLAT("\nIn main().")
   BLAT("ItemsNum = " << Settings.ItemsNum)
   BLAT("ItemsStr = " << Settings.ItemsStr << "\n")

   // If recursing, pass ProcessCurDir to CursDirs; else, just run ProcessCurDir():
   if (Settings.bRecurse)
   {
      rhdir::CursDirs(ProcessCurDir);
   }
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
ns_FindSpaceyFileNames::
ProcessFlags
   (
      VS          const  &  Flags,
      Settings_t         &  Settings
   )
{
   BLAT("\nJust entered ProcessFlags().  About to set settings.\n")

   // Use InVec from rhutil:
   using rhutil::InVec;

   Settings.bHelp    = InVec(Flags, "-h") or InVec(Flags, "--help"   );
   Settings.bRecurse = InVec(Flags, "-r") or InVec(Flags, "--recurse");
   Settings.bVerbose = InVec(Flags, "-v") or InVec(Flags, "--verbose");

   // Start with ItemsNum set to 1 and ItemsStr set to "files":
   Settings.ItemsNum = 1;
   Settings.ItemsStr = "files";

   // Update ItemsNum and ItemsStr if warranted by flags:

   if (InVec(Flags, "-d") or InVec(Flags, "--directories"))
   {
      Settings.ItemsNum = 2;
      Settings.ItemsStr = "directories";
   }

   if (InVec(Flags, "-b") or InVec(Flags, "--both"))
   {
      Settings.ItemsNum = 3;
      Settings.ItemsStr = "files and directories";
   }

   BLAT("About to return from ProcessFlags.\n")
   return;
} // end ns_FindSpaceyFileNames::ProcessFlags()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessArguments()                                                      //
//                                                                          //
//  Sets program settings based on Arguments.                               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_FindSpaceyFileNames::
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
} // end ns_FindSpaceyFileNames::ProcessArguments()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurDirFunctor::operator()                                        //
//                                                                          //
//  Processes current directory.                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void ns_FindSpaceyFileNames::ProcessCurDirFunctor::operator() (void)
{
   BLAT("\nJust entered ProcessCurDirFunctor::operator().\n")
   // Increment directory counter:
   ++Stats.DirCount;

   // If user used "-v" or "--verbose" flags, annouce processing current directory:
   if (Settings.bVerbose)
   {
      // Get the current directory:
      std::string CurDir = rhdir::GetFullCurrPath();

      cout
         << endl
         << "==============================================================================" << endl
         << "Now processing directory #" << Stats.DirCount << ":" << endl
         << CurDir << endl
         << endl;
   }

   // Get vector of file records for all items in current directory which match
   // the wildcards given by the command-line arguments, if any.
   // If no arguments were given, get all items of type(s) given by Settings.ItemsNum:
   FileList.clear();
   if (Arguments.size() > 0)
   {
      std::string Wildcard;
      for (VSCI i = Arguments.begin(); i != Arguments.end(); ++i)
      {
         Wildcard = *i;
         rhdir::LoadFileList
         (
            FileList,           // Name of container to load.
            Wildcard,           // Item-name wildcard.
            Settings.ItemsNum,  // 1 = Files only, 2 = Dirs only, 3 = both
            2                   // Append to list without clearing.
         );
      }
   }
   else // Otherwise, get all items of type specified by Settings.ItemNum:
   {
      rhdir::LoadFileList
      (
         FileList,           // Name of container to load.
         "*",                // Get all items.
         Settings.ItemsNum,  // 1 = Files only, 2 = Dirs only, 3 = both
         2                   // Append to list without clearing.
      );
   }

   BLAT("\nIn ProcessCurDirFunctor::operator().")
   BLAT("Finished building file list.")
   BLAT("File list size is " << FileList.size())
   BLAT("About to enter file-iteration for loop.\n")

   /* --------------------------------------------------------------- */
   /*  Iterate through items, listing items with bad names:           */
   /* --------------------------------------------------------------- */
   for ( VFRI  i = FileList.begin() ; i != FileList.end() ; ++i )
   {
      ProcessCurrentFile(Settings, Arguments, Stats, *i);
   } // end for (each file in FileList)
   BLAT("\nAt end of ProcessCurDirFunctor::operator(), about to return.\n")
   return;
} // end ns_FindSpaceyFileNames::ProcessCurDirFunctor::operator()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurrentFile()                                                    //
//                                                                          //
//  Processes current file.                                                 //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_FindSpaceyFileNames::
ProcessCurrentFile
   (
      Settings_t  const  &  Settings,
      VS          const  &  Arguments,
      Stats_t            &  Stats,
      FR          const  &  FileRecord
   )
{
   // This program lists the names of all files with spacey names.

   // Note: it's best to run "find-bad-file-names.exe" before running this program, else unexpected results
   // may be obtained.

   ++Stats.FilCount;

   if ( std::string::npos != FileRecord.name.find(' ') )
   {
      ++Stats.SpcCount;
      cout << FileRecord.path() << endl;
   }

   return;
} // end ns_FindSpaceyFileNames::ProcessCurrentFile()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Help()                                                                  //
//                                                                          //
//  Prints help.                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_FindSpaceyFileNames::
Help
   (
      void
   )
{
   //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
   cout
   << "Welcome to Find Spacey File Names, Robbie Hatley's spacey-file-name finding"            << endl
   << "utility!"                                                                               << endl
                                                                                               << endl
   << "This version compiled at " << __TIME__ << " on " << __DATE__ << "."                     << endl
                                                                                               << endl
   << "Command-line syntax:"                                                                   << endl
   << "find-spacey-file-names [switches] [arguments] < InputFile > OutputFile"                 << endl
                                                                                               << endl
   << "Switch:                          Meaning:"                                              << endl
   << "\"-h\" or \"--help\"             Print help and exit."                                  << endl
   << "\"-r\" or \"--recurse\"          Process all subdirectories."                           << endl
   << "\"-v\" or \"--verbose\"          Announce each directory processed."                    << endl
   << "\"-d\" or \"--directories\"      Process directories only."                             << endl
   << "\"-b\" or \"--both\"             Process both files and directories."                   << endl
                                                                                               << endl
   << "Find-bad-file-names prints the paths of all files in the current directory"             << endl
   << "(and all of its subdirectories, if an \"-r\" or \"--recurse\" switch is used)"          << endl
   << "which have names containing embedded spaces."                                           << endl
                                                                                               << endl
   << "By default, this program only processes files.  To process only directories,"           << endl
   << "use a \"-d\" or \"--directories\" flag.  Or, to process both files and directories,"    << endl
   << "use a \"-b\" or \"--both\" flag."                                                       << endl
                                                                                               << endl
   << "For best results, run \"find-bad-file-names.exe\" before running this program,"         << endl
   << "or unexpected results may be obtained."                                                 << endl
                                                                                               << endl;
   return;
} // end ns_FindSpaceyFileNames::Help()

// end file find-spacey-file-names.cpp
