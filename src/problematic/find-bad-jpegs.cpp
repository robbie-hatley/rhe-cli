
/************************************************************************************************************\
 * Program name:  find-bad-jpegs
 * Description:   Finds *.jpg files which do NOT begin with the 3 bytes "255, 216, 255", and segregates them.
 * File name:     find-bad-jpegs.cpp
 * Source for:    find-bad-jpegs.exe
 * Author:        Robbie Hatley
 * Date written:  Fri Sep 12, 2008
 * Edit History:
 *   Fri Sep 12, 2008 - Wrote skeletal version.  EXTREME STUBB!!!
 *   Sat Sep 20, 2008 - Put in directory iteration stuff, but still an extreme stubb.
 *   Wed Oct 01, 2008 - Got it to work, sort-off, but needs fine-tuning.
 *   Fri Oct 03, 2008 - Took out call to system("move....").  Now using rename() instead.  Only works
 *                      within one drive this way, but can handle much longer command lines.  Also corrected
 *                      some errors in the help function.
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


namespace ns_FndBadJpg
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
   typedef  LFR::const_iterator       LFRCI; // std::list<rhdir::FileRecord>::const_iterator == LFRCI
   typedef  std::vector<FR>           VFR;
   typedef  VFR::iterator             VFRI;
   typedef  VFR::const_iterator       VFRCI;

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
               Bools_t  const  &  Bools_,
               VS       const  &  Arguments_,
               Stats_t         &  Stats_,
               VFR             &  FileRecords_
            )
            : Bools(Bools_), Arguments(Arguments_), Stats(Stats_), FileRecords(FileRecords_)
            {}
         void operator()(void); // defined below
      private:
         Bools_t  const  &  Bools;
         VS       const  &  Arguments;
         Stats_t         &  Stats;
         VFR             &  FileRecords;
   };

   void
   ProcessCurrentFile
   (
      Bools_t  const  &  Bools,
      VS       const  &  Arguments,
      Stats_t         &  Stats,
      VFR      const  &  FileRecords,
      FR       const  &  FilRec
   );
   std::string GetBadDir (std::string FullCurrPath);
   void Help (void);
} // end namespace ns_FndBadJpg



//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  main()                                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

int main (int Beren, char * Luthien[])
{
   using namespace ns_FndBadJpg;
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
   ProcessCurDirFunctor ProcessCurDir (Bools, Arguments, Stats, FileRecords);

   // Recurse if recursing:
   if (Bools.bRecurse)
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
ns_FndBadJpg::
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
} // end ProcessFlags()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurDirFunctor::operator()                                        //
//                                                                          //
//  Processes current directory.                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void ns_FndBadJpg::ProcessCurDirFunctor::operator() (void)
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

   // Now, let's add all jpeg files to our file-records vector.

   // BONEHEAD RH 2009-05-18: No, on second thought, let's not.
   // First, let's CLEAR the zarking vector!!!!!!!!!!!!!!!!!!!!

   FileRecords.clear();

   // (Got bit by that bug.  Couldn't open files in one directory which were
   // actually left over in FileRecords from previous directories.  But it
   // only took me about 2 minutes to figure out where the bug was, which
   // proves I'm actually a pretty cool frood who really knows where his
   // towel is.)

   // NOW, we're finally read to add all jpeg files to the vector.

   // First, add all "*.jpg" files to the vector:
   rhdir::LoadFileList
   (
      FileRecords,  // Name of container to load.
      "*.jpg",      // File-name wildcard.
      1,            // FileRecords only (not dirs).
      2             // Append to list without clearing.
   );

   // Also add all "*.jpeg" files to the vector:
   rhdir::LoadFileList
   (
      FileRecords,  // Name of container to load.
      "*.jpeg",     // File-name wildcard.
      1,            // FileRecords only (not dirs).
      2             // Append to list without clearing.
   );

   // Also add all "*.pjpeg" files to the vector :
   rhdir::LoadFileList
   (
      FileRecords,  // Name of container to load.
      "*.pjpeg",    // File-name wildcard.
      1,            // FileRecords only (not dirs).
      2             // Append to list without clearing.
   );

   // Create a standard input file stream:
   std::ifstream Fred;

   // Make an array of 3 chars and an array of 3 unsigned ints:
   char          First3Chrs [3] = {0};
   unsigned int  First3Ints [3] = {0};

   // Make an error-code variable:
   int ErrorCode = 0;

   // Make a "current file is bad" boolean variable:
   bool CurrFileIsBad = false;

   // Get the full path of the "Bad" directory corresponding to the current directory:
   std::string BadDir = GetBadDir(CurDir);

   BLAT("In program find-bad-jpegs, near top of ProcessCurrDir():")
   BLAT("GetBadDir returned:  ")
   BLAT(BadDir)

   // Haven't found any bad jpegs in this directory yet:
   bool FoundBadJpegs = false;

   // Iterate through the files, looking for bad jpeg files:
   for ( VFRCI iter = FileRecords.begin(); iter != FileRecords.end(); ++iter )
   {
      // Increment file counter:
      ++Stats.FilCount;

      // Attempt to open current file in binary, read-only mode:
      Fred.open(iter->name.c_str(), std::ios::in|std::ios::binary);

      // If open attempt failed, print error and go on to next file:
      if (!Fred.is_open())
      {
         cerr << "Error in find-bad-jpegs.exe: can't open file "    << endl;
         cerr << iter->name                                         << endl;
         cerr << " for binary input.  Continuing to next file...."  << endl;
         ++Stats.ErrCount;
         continue;
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

      BLAT("First 3 bytes of file " << iter->name << " are " << endl \
      << std::setfill(' ') \
      << std::setw(4) << First3Ints[0] \
      << std::setw(4) << First3Ints[1] \
      << std::setw(4) << First3Ints[2] )

      // Since all valid *.jpg files start with (255, 216, 255), mark file as "bad" if
      // it doesn't start with these 3 bytes:
      CurrFileIsBad = !(255 == First3Ints[0] && 216 == First3Ints[1] && 255 == First3Ints[2]);

      // If current file is bad, move it to a "Bad" directory:
      if (CurrFileIsBad)
      {
         // Annouce bad file:
         cout << iter->path() << endl;

         // Increment bad-file counter:
         ++Stats.BadCount;

         // If we get to here, this directory definitely has at least one bad jpeg file:
         FoundBadJpegs = true;

         // If BadDir doesn't already exist, create it:
         if (!__file_exists(BadDir.c_str()))
         {
            ErrorCode = mkdir(BadDir.c_str(), S_IWUSR);
            if (ErrorCode)
            {
               cerr << "Error in find-bad-jpegs, in function ProcessCurDir():" << endl;
               cerr << "Couldn't create directory " << BadDir << endl;
               cerr << "mkdir returned this error code:" << endl;
               cerr << strerror(errno) << endl;
               cerr << "Aborting processing current directory and moving on to next." << endl;
               return; // Abort processing current directory.
            }
         }

         // Move the bad file to its new home:
         std::string Source = iter->name;
         std::string Destin = BadDir + '\\' + iter->name;
         BLAT("In program find-bad-jpegs, in function ProcessCurDir():")
         BLAT("About to attempt the following file rename:")
         BLAT("Old Name: " << Source)
         BLAT("New Name: " << Destin)
         ErrorCode = rename(Source.c_str(), Destin.c_str());
         if (ErrorCode)
         {
            cerr << "Error in find-bad-jpegs, in function ProcessCurDir():" << endl;
            cerr << "Couldn't rename " << Source << " to " << Destin << endl;
            cerr << "rename() generated the following error:" << endl;
            cerr << strerror(errno) << endl;
            cerr << "Continuing with next file." << endl;
            ++Stats.ErrCount;
            continue;
         }

      } // end if (current file is bad)

      // Otherwise, if current file is good, just bypass it:
      else
      {
         ++Stats.BypCount;
      }

   } // end for (each file n FileRecords)

   // If we found one or more bad jpegs in this directory, increment DbjCount:
   if (FoundBadJpegs) ++Stats.DbjCount;

   // Finished processing current directory:
   return;
} // end ProcessCurDirFunctor::operator()


///////////////////////////////////////////////////////////////////////////
//                                                                       //
//  GetBadDir()                                                          //
//                                                                       //
//  Returns appropriate name for subdirectory of Bad, named after the    //
//  the original directory the files came from.                          //
//                                                                       //
///////////////////////////////////////////////////////////////////////////

std::string
ns_FndBadJpg::
GetBadDir
   (
      std::string FullCurrPath
   )
{
   // Make a name for it:
   std::string Name = FullCurrPath;

   // Make an index:
   std::string::size_type Index;

   // Replace colons with backticks:
   while (std::string::npos != (Index = Name.find(':')))
   {
      Name.replace(Index, 1, 1, '`');
   }

   // Replace dots with backticks:
   while (std::string::npos != (Index = Name.find('.')))
   {
      Name.replace(Index, 1, 1, '`');
   }

   // Replace slashes with underscores:
   while (std::string::npos != (Index = Name.find('/')))
   {
      Name.replace(Index, 1, 1, '_');
   }

   // Replace backslashes with underscores:
   while (std::string::npos != (Index = Name.find('\\')))
   {
      Name.replace(Index, 1, 1, '_');
   }

   // Tack "\\Bad\\" on the front:
   Name =  "\\Bad\\" + Name;

   // Return Name:
   return Name;

} // end GetBadDir()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Help()                                                                  //
//                                                                          //
//  Prints help.                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_FndBadJpg::
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

