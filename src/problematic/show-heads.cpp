
/************************************************************************************************************\
 * Program name:  show-heads
 * Description:   Displays the first three bytes of each file.  Also sets extention to match if -e or
 *                --extention switch is used.
 * File name:     show-heads.cpp
 * Source for:    show-heads.exe
 * Author:        Robbie Hatley
 * Edit History:
 *   Wed Jan 26, 2011 - Started writing it.
\************************************************************************************************************/

#include <cstdlib>
#include <cstring>
#include <ctime>

#include <iostream>
#include <iomanip>
#include <list>
#include <string>

#include <unistd.h>
#include <sys/stat.h>

#define NDEBUG
#undef  NDEBUG

#include <assert.h>
#include <errno.h>

#define BLAT_ENABLE
#undef  BLAT_ENABLE

#include "rhutil.hpp"
#include "rhdir.hpp"


namespace ns_ShwHds
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

   struct Settings_t     // program boolean settings
   {
      bool bHelp;     // Did user ask for help?
      bool bRecurse;  // Walk directory tree downward from current node?
   };

   void
   ProcessFlags
   (
      VS          const  &  Flags,
      Settings_t         &  Settings
   );

   struct Stats_t     // program run-time statistics
   {
      uint32_t  DirCount;  // Count of directories processed.
      uint32_t  DbjCount;  // Count of directories with bad jpegs.
      uint32_t  FilCount;  // Count of jpeg files examined.
      uint32_t  BypCount;  // Count of good jpeg files bypassed.
      uint32_t  ErrCount;  // Count of errors encountered.
      uint32_t  BadCount;  // Count of bad jpeg files successfully segregated.
      void PrintStats (void)
      {
         cout
                                                                                            << endl
            << "Finished processing files in this tree."                                    << endl
            << "Processed   " << setw(7) << DirCount << " directories."                     << endl
            << "Found       " << setw(7) << DbjCount << " directories with bad jpeg files." << endl
            << "Examined    " << setw(7) << FilCount << " total jpeg files."                << endl
            << "Bypassed    " << setw(7) << BypCount << " good jpeg files."                 << endl
            << "Encountered " << setw(7) << ErrCount << " errors."                          << endl
            << "Segregated  " << setw(7) << BadCount << " bad jpeg files."                  << endl
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
               VFR                &  FileRecords_
            )
            : Settings(Settings_), Arguments(Arguments_), Stats(Stats_), FileRecords(FileRecords_)
            {}
         void operator()(void); // defined below
      private:
         Settings_t  const  &  Settings;
         VS          const  &  Arguments;
         Stats_t            &  Stats;
         VFR                &  FileRecords;
   };

   void
   ProcessCurrentFile
   (
      Settings_t  const  &  Settings,
      Stats_t            &  Stats,
      FR          const  &  FileRec
   );

   std::string GetBadDir (std::string FullCurrPath);
   void Help (void);
} // end namespace ns_ShwHds



//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  main()                                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

int main (int Beren, char * Luthien[])
{
   using namespace ns_ShwHds;
   srand(time(0));
   VS Flags;
   rhutil::GetFlags (Beren, Luthien, Flags);

   Settings_t Settings = Settings_t();
   ProcessFlags(Flags, Settings);

   if (Settings.bHelp)
   {
      Help();
      return 777;
   }

   // If there is no "Bad" directory in the root of the current drive,
   // make it:
   if (!__file_exists("/Bad")) mkdir("/Bad",  S_IWUSR);

   // Make a vector to hold arguments, and load the arguments into the vector:
   VS Arguments;
   rhutil::GetArguments(Beren, Luthien, Arguments);

   // Make an object to hold run-time stats for this instance of this
   // application:
   Stats_t Stats = Stats_t();

   // Make a vector to hold a list of files,  reserve 10000 slots, and clear:
   static VFR FileRecords;
   FileRecords.reserve(10000);
   FileRecords.clear();

   // Make a current-directory-processing function-object:
   ProcessCurDirFunctor ProcessCurDir (Settings, Arguments, Stats, FileRecords);

   // Recurse if recursing:
   if (Settings.bRecurse)
   {
      rhdir::CursDirs(ProcessCurDir);
   }

   // Else don't recurse:
   else
   {
      ProcessCurDir();
   }

   // Print stats and scram:
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
ns_ShwHds::
ProcessFlags
   (
      VS       const  &  Flags,
      Settings_t         &  Settings
   )
{
   BLAT("\nJust entered ProcessFlags().  About to set Settings.\n")

   // Use InVec from rhutil:
   using rhutil::InVec;

   Settings.bHelp    = InVec(Flags, "-h") or InVec(Flags, "--help"   );
   Settings.bRecurse = InVec(Flags, "-r") or InVec(Flags, "--recurse");

   BLAT("About to return from ProcessFlags.\n")
   return;
} // end ProcessFlags()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurDirFunctor::operator()                                        //
//                                                                          //
//  Processes current directory.                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void ns_ShwHds::ProcessCurDirFunctor::operator() (void)
{
   // ABSTRACT:
   // This function announces the current directory, then finds and segregates all "*.jpg" files
   // in the current directory which do not have headers beginning with 255, 216, 255.

   // Increment directory counter:
   ++Stats.DirCount;

   // Get the current path:
   std::string CurDir = rhdir::GetFullCurrPath();

   // Announce processing current directory:
   cout
      << endl
      << "==============================================================================" << endl
      << "Now processing directory #" << Stats.DirCount << ":" << endl
      << CurDir << endl
      << endl;

   // Add all files:
   rhdir::LoadFileList
   (
      FileRecords,  // Name of container to load.
      "*",          // File-name wildcard (all files).
      1,            // Files only (not dirs).
      1             // Clear list before adding files.
   );

   // Iterate through the files, executing ProcessCurrentFile() for each file:
   for ( VFRCI iter = FileRecords.begin(); iter != FileRecords.end(); ++iter )
   {
      ProcessCurrentFile(Settings, Stats, (*iter));
   }

   // Finished processing current directory:
   return;

} // end ProcessCurDirFunctor::operator()



//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurrentFile()                                                    //
//                                                                          //
//  Processes current file.                                                 //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_ShwHds::
ProcessCurrentFile
   (
      Settings_t  const  &  Settings,
      Stats_t            &  Stats,
      FR          const  &  FileRec
   )
{
   // Increment file counter:
   ++Stats.FilCount;

   // Create a standard input file stream:
   std::ifstream Fred;

   // Make an array of 3 chars and an array of 3 unsigned ints:
   char          First3Chrs [4] = {' ', ' ', ' ', '\0'};
   unsigned int  First3Ints [3] = {0,0,0};

   // Attempt to open current file in binary, read-only mode:
   Fred.open(FileRec.name.c_str(), std::ios::in|std::ios::binary);

   // If open attempt failed, print error and go on to next file:
   if (!Fred.is_open())
   {
      cerr << "Error in find-bad-jpegs.exe: can't open file "    << endl;
      cerr << FileRec.name                                       << endl;
      cerr << " for binary input.  Continuing to next file...."  << endl;
      ++Stats.ErrCount;
      return;
   }

   // Read first 3 bytes into array FirstThreeChrs:
   Fred.read(First3Chrs, 3);

   // Close current file:
   Fred.close();

   // Convert each byte first to unsigned char to get 0 to 255 range,
   // then to unsigned int, so it will print as a number rather than a character:
   for ( int i = 0 ; i < 3 ; ++i )
   {
      First3Ints[i]
         = static_cast<unsigned int>(static_cast<unsigned char>(First3Chrs[i]));
   }

   cout << "First 3 characters of file " << FileRec.name << " are " << First3Chrs << endl;

   cout 
   << "First 3 bytes of file " << FileRec.name << " are " << endl
   << std::setfill(' ')
   << std::setw(4) << First3Ints[0]
   << std::setw(4) << First3Ints[1]
   << std::setw(4) << First3Ints[2]
   << endl;

   return;

}


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Help()                                                                  //
//                                                                          //
//  Prints help.                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_ShwHds::
Help
   (
      void
   )
{
   //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
   cout
   << "Welcome to find-bad-jpegs, Robbie Hatley's bad-jpeg-file-finding utility."              << endl
                                                                                               << endl
   << "This version compiled at " << __TIME__ << " on " << __DATE__ << "."                     << endl
                                                                                               << endl
   << "Command-line syntax:"                                                                   << endl
   << "redir -o bad-jpeg-log.txt -eo find-bad-jpegs [switches]"                                << endl
                                                                                               << endl
   << "Switch:                      Meaning:"                                                  << endl
   << "\"-h\" or \"--help\"             Print help and exit."                                  << endl
   << "\"-r\" or \"--recurse\"          Process all subdirectories."                           << endl
                                                                                               << endl
   << "This program finds, lists, and segregates all \"*.jpg\" files in the current"           << endl
   << "directory (and all of its subdirectories, if a \"-r\" or \"--recurse\" switch"          << endl
   << "is used) which do not start with the bytes 255, 216, 255.  Any \"*.jpg\" file"          << endl
   << "which does not start with these bytes is bad and may be unreadable by some"             << endl
   << "or all graphics editors and viewers.  Such bad \"*.jpg\" files may crash"               << endl
   << "your graphics program or even your operating system.  To prevent such problems,"        << endl
   << "this program segregates such files in subfolders of a folder called \"Bad\" on"         << endl
   << "the root of the current drive.  (If \"Bad\" doesn't already exist, this program"        << endl
   << "will create it.)  Each subfolder is named after the path its files came from."          << endl;
   return;
} // end Help()

// end file find-bad-jpegs.cpp

