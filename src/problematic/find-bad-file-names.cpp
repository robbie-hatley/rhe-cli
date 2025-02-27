
/************************************************************************************************************\
 * Program name:  Find Bad File Names
 * Description:   Finds any files in the current directory (and all its subdirectories if an "-r" or
 *                "--recurse" switch is used) which have names which are so malformed that programs compiled
 *                using djgpp can't open them.  This is usually due to the names containing characters from
 *                iso-8859-1 which are not in the Microsoft Windows character sets (known as "code pages").
 * File name:     find-bad-file-names.cpp
 * Source for:    find-bad-file-names.exe
 * Author:        Robbie Hatley
 * Date written:  Wed Sep 24, 2008
 * Actions:       For each file in the current directory (and all its subdirectories if a "-r" or "--recurse"
 *                switch is used), runs djgpp's function __file_exists() on the file name loaded into a list
 *                of file records by function rhdir::LoadFileList().  If __file_exists() returns false, the
 *                file name probably contains non-ASCII iso-8859-1 or Unicode characters.  Such characters
 *                confuse the command console (cmd.exe) and many programs, which convert them to similar-
 *                looking ASCII characters within the programs' file lists.  Then when such programs attempt
 *                to copy, move, or delete such files, they can't, because their own, ASCII-ized versions of
 *                the file names don't match the iso-8859-1 or Unicode versions which Windows stores in its
 *                long file names.  Hence such files should be re-named, using only a "safe" subset of ASCII
 *                characters.
 * Inputs:        Command-line switches only.  (No arguments, and no interactive inputs.)
 * Outputs:       Announces each directory processed, and lists all files found to have bad names.
 * To make:       Link with modules rhutil.o and rudir.o in library librh.a
 * Edit History:
 *    Wed Sep 24 2008 - Wrote it.
 *    Thu Mar 04 2010 - Now flags a file name as "invalid" if *either* of the following is true:
 *                      1. __file_exists() can't find the file.
 *                      2. rhdir::FileNameIsInvalid(FileName) returns true.
 *                      This more-closely mirrors the highly-restrictive definition of "invalid" file names
 *                      used by EFN, DFN, etc.
 *    Sun Dec 19 2010 - Rewrote using "ProcessCurDirFunctor" approach.
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

namespace ns_FindBadFileNames
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
      uint32_t  BadCount;  // Count of bad file names found.
      uint32_t  ErrCount;  // Count of errors encountered.
      void PrintStats (void)
      {
         cout
                                                                        << endl
            << "Finished processing files in this tree."                << endl
            << "Directories processed:        " << setw(7) << DirCount  << endl
            << "Files examined:               " << setw(7) << FilCount  << endl
            << "Bad file names found:         " << setw(7) << BadCount  << endl
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
   using namespace ns_FindBadFileNames;

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
ns_FindBadFileNames::
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
} // end ns_FindBadFileNames::ProcessFlags()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessArguments()                                                      //
//                                                                          //
//  Sets program settings based on Arguments.                               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_FindBadFileNames::
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
} // end ns_FindBadFileNames::ProcessArguments()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurDirFunctor::operator()                                        //
//                                                                          //
//  Processes current directory.                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void ns_FindBadFileNames::ProcessCurDirFunctor::operator() (void)
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
} // end ns_FindBadFileNames::ProcessCurDirFunctor::operator()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurrentFile()                                                    //
//                                                                          //
//  Processes current file.                                                 //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_FindBadFileNames::
ProcessCurrentFile
   (
      Settings_t  const  &  Settings,
      VS          const  &  Arguments,
      Stats_t            &  Stats,
      FR          const  &  FileRecord
   )
{
   ++Stats.FilCount;

   // To determine whether a file name returned by findfirst()/findnext() (which use a subset of
   // iso-8859-1) is equal to the actual Windows long file name (which uses unicode), use function
   // "__file_exists()" from djgpp's non-standard "unicode.hpp" header.  djgpp's documentation for this
   // function reads: "This function provides a fast way to ask if a given file exists. Unlike access(),
   // this function does not cause other objects to get linked in with your program, so is used primarily
   // by the startup code to keep minimum code size small."  ("Startup" of what, exactly, the
   // documentation doesn't specify.)  I use it here in an attempt to "get closer to the machine".
   // 
   // Also, even if __file_exists() *does* say a file exists, in order for this program to consider
   // the file's name to be valid, it must not be flagged as "invalid" by function
   // rhdir::FileNameIsInvalid().  This is a very restrictive function which allows file names to
   // contain only a sharply-limited subset of ASCII characters, selected to prevent problems
   // accross a spectrum of platforms.
   // 
   // Hence, this function (and hence this program) is very, very exclusive.  Any file names which do not
   // meet its it's standards are flagged as "bad".  This does not imply that such names are "invalid"
   // from the standpoint of Windows-2000's or Windows-XP's explorer; but such files may very well be
   // "invalid" in other contexts, such as "cmd.exe" or my utility programs.

   if ( rhdir::FileNameIsInvalid(FileRecord.name) or not __file_exists(FileRecord.name.c_str()) )
   {
      ++Stats.BadCount;
      cout << FileRecord.path() << endl;
   }

   return;
} // end ns_FindBadFileNames::ProcessCurrentFile()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Help()                                                                  //
//                                                                          //
//  Prints help.                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_FindBadFileNames::
Help
   (
      void
   )
{
   //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
   cout
   << "Welcome to Find Bad File Names, Robbie Hatley's bad-file-name finding utility!"         << endl
                                                                                               << endl
   << "This version compiled at " << __TIME__ << " on " << __DATE__ << "."                     << endl
                                                                                               << endl
   << "Command-line syntax:"                                                                   << endl
   << "find-bad-file-names [switches] < InputFile > OutputFile"                                << endl
                                                                                               << endl
   << "Switch:                          Meaning:"                                              << endl
   << "\"-h\" or \"--help\"             Print help and exit."                                  << endl
   << "\"-r\" or \"--recurse\"          Process all subdirectories."                           << endl
   << "\"-v\" or \"--verbose\"          Announce each directory processed."                    << endl
   << "\"-d\" or \"--directories\"      Process directories only."                             << endl
   << "\"-b\" or \"--both\"             Process both files and directories."                   << endl
                                                                                               << endl
   << "Find-bad-file-names finds all files in the current directory (and all of its"           << endl
   << "subdirectories, if an \"-r\" or \"--recurse\" switch is used) which have names"         << endl
   << "which are not correctly returned by djgpp's findfirst() and findnext(),"                << endl
   << "or which contain any of various illegal or troublesome characters.  Files with"         << endl
   << "such names can't be processed by my homebrew utility programs, because the name"        << endl
   << "the program gets from findfirst()/findnext() is not the same as the named used"         << endl
   << "by rename() or the OS, so such files can't be opened, renamed, or moved."               << endl
   << "To fix this, manually rename such files using only \"safe\" characters, so that"        << endl
   << "this program doesn't flag the file as having an invalid name."                          << endl
                                                                                               << endl
   << "By default, this program only processes files.  To process only directories,"           << endl
   << "use a \"-d\" or \"--directories\" flag.  Or, to process both files and directories,"    << endl
   << "use a \"-b\" or \"--both\" flag."                                                       << endl
                                                                                               << endl
   << "Find Bad File Names will list the full path of each file found which has a bad"         << endl
   << "name.  Note that the file names listed will rarely be fully identical to the"           << endl
   << "actual file names.  (If they were, they probably wouldn't have been flaged by"          << endl
   << "this program in the first place!)  Instead, this program will list the names"           << endl
   << "as it got them from djgpp's findfirst() and findnext() functions.  These should"        << endl
   << "be close enough to the actual file names to allow the user to intuit what the"          << endl
   << "actual name is and find and rename the file manually."                                  << endl
                                                                                               << endl;
   return;
} // end ns_FindBadFileNames::Help()

// end file find-bad-file-names.cpp
