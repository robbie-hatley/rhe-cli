
/************************************************************************************************************\
 * Program name:  set-extensions
 * Description:   Sets file extensions of files in current directory based on first few bytes of each file.
 * File name:     set-extensions.cpp
 * Source for:    set-extensions.exe
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

#undef  NDEBUG
#define NDEBUG

#include <assert.h>
#include <errno.h>

#define BLAT_ENABLE
#undef  BLAT_ENABLE

#include "rhutil.hpp"
#include "rhdir.hpp"


namespace ns_SetExt
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
      bool bHelp;     // Did user ask for help?
      bool bRecurse;  // Walk directory tree downward from current node?
   };

   void
   ProcessFlags       // Set settings based on flags.
   (
      VS          const  &  Flags,
      Settings_t         &  Settings
   );

   struct Stats_t     // program run-time statistics
   {
      uint32_t  DirCount;  // Count of directories processed.
      uint32_t  FilCount;  // Count of files examined.
      uint32_t  TypCount;  // Count of files of  known  type.
      uint32_t  UnkCount;  // Count of files of unknown type.
      uint32_t  BypCount;  // Count of files bypassed.
      uint32_t  AttCount;  // Count of file renames attempted.
      uint32_t  RenCount;  // Count of file renames succeeded.
      uint32_t  ErrCount;  // Count of file renames failed.
      void PrintStats (void)
      {
         cout
                                                                     << endl
            << "Finished processing files in this tree."             << endl
            << "Directories processed:     " << setw(7) << DirCount  << endl
            << "Files examined:            " << setw(7) << FilCount  << endl
            << "Files of known type:       " << setw(7) << TypCount  << endl
            << "Files of unknown type:     " << setw(7) << UnkCount  << endl
            << "Files bypassed:            " << setw(7) << BypCount  << endl
            << "File renamed attempted:    " << setw(7) << AttCount  << endl
            << "File renames succeeded:    " << setw(7) << RenCount  << endl
            << "File renames failed:       " << setw(7) << ErrCount  << endl
                                                                     << endl;
      }
   };

   // Main current-directory-processing functor declaration follows.  If necessary, other data
   // (such as Flags) can also be stored in instantiations of this functor; but for this template, 
   // I'm just storing Settings, Arguments, Stats, and a reference to the file list.
   // Also remember that all of the member variables can be set to either const or non-const 
   // as the needs of each application demand.

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
         Stats_t            &  Stats;     // Non-const so function can increment stats counters.
         VFR                &  FileList;  // Non-const so function can clear/write file list.
   };

   // For programs that process individual files, this next function is "the function that does
   // all the real work of the program".  This may be just gleaning info from a file, or altering
   // the contents of a file, or perhaps renaming it.  This function is intended to be called
   // from a for loop in ProcessCurDirFunctor:

   void
   ProcessCurrentFile
   (
      Settings_t  const  &  Settings,
      Stats_t            &  Stats,
      FR          const  &  FileRecord
   );

   void Help (void);

} // end namespace ns_SetExt



//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  main()                                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

int main (int Beren, char * Luthien[])
{
   // Set main namespace we're using:
   using namespace ns_SetExt;

   // Seed random-number generator (this can be deleted if not using random numbers):
   srand(time(0));

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

   // Make a stats object to hold program run-time statistics:
   Stats_t Stats = Stats_t();

   // Make a vector of file records (in "static" memory instead of the stack, else this can very easily
   // overflow the stack!!!):
   static VFR FileList;

   // Reserve room for info on 10,000 files (this Allocates memory for 10,000 items, but it doesn't
   // actually bloat the vector to that size yet; it just creates contiguous block of 10,000 cells
   // of "reserved-but-unused" space, so that we don't have to keep re-allocating as the vector grows):
   FileList.reserve(10000);

   // Create a function object of type "ProcessCurDirFunctor" for use with CursDirs:
   ProcessCurDirFunctor ProcessCurDir (Settings, Arguments, Stats, FileList);

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
//  Sets program-state booleans based on Flags.                             //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_SetExt::
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
} // end ns_SetExt::ProcessFlags()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurDirFunctor::operator()                                        //
//                                                                          //
//  Processes current directory.                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void ns_SetExt::ProcessCurDirFunctor::operator() (void)
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
      FileList,  // Name of container to load.
      "*",          // File-name wildcard (all files).
      1,            // Files only (not dirs).
      1             // Clear list before adding files.
   );

   // Iterate through the files, executing ProcessCurrentFile() for each file:
   for ( VFRCI iter = FileList.begin(); iter != FileList.end(); ++iter )
   {
      ProcessCurrentFile(Settings, Stats, (*iter));
   }

   // Finished processing current directory:
   return;

} // end ns_SetExt::ProcessCurDirFunctor::operator()



//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurrentFile()                                                    //
//                                                                          //
//  Processes current file.                                                 //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_SetExt::
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

   // Make an array of 50 chars and an array of 50 unsigned ints:
   char          First50Chrs [50] = {'\0'};
   unsigned int  First50Ints [50] = {0};

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

   // Read first 50 bytes into array First50Chrs:
   Fred.read(First50Chrs, 50);

   // Close current file:
   Fred.close();

   // Convert each byte first to unsigned char to get 0 to 255 range,
   // then to unsigned int, so it will print as a number rather than a character:
   for ( int i = 0 ; i < 50 ; ++i )
   {
      First50Ints[i]
         = static_cast<unsigned int>
           (
              static_cast<unsigned char>
              (
                 First50Chrs[i]
              )
           );
   }

   // Re-set extension if it doesn't match header:

   std::string OldName = FileRec.name;
   std::string NewName = OldName;
   std::string Prefix  = rhdir::GetPrefix(OldName);
   std::string NewSuff = ".unk";



   // ~~~~~~~~~~~~~~~~~~~~ BEGIN FILE-TYPE-DETERMINATION SECTION: ~~~~~~~~~~~~~~~~~~~~

   bool bIsTxt = true;
   for ( int i = 0 ; i < 50 ; ++i )
   {
      if 
         (
            !(                      // Character is not glyphical
                First50Ints[i] > 32
                && 
                First50Ints[i] < 128
             )
            &&                      // and
             9 != First50Ints[i]    // character is not horizontal tab
            &&                      // and
            10 != First50Ints[i]    // character is not carriage return
            &&                      // and
            13 != First50Ints[i]    // character is not line feed
            &&                      // and
            32 != First50Ints[i]    // character is not space
         )
      {
         bIsTxt = false;
         break;
      }
   }

   // ======= HTML ======= :
   // ======= TXT  ======= :

   if (bIsTxt)
   {
      if ("<!DOCTYPE HTML" == std::string(First50Chrs+0,14))
      {
         NewSuff = ".html";
      }
      else
      {
         NewSuff = ".txt";
      }
   }

   // ======= AVI ======= :

   else if ( "AVI" == std::string(First50Chrs+8,3) )
   {
      NewSuff = ".avi";
   }

   // ====== CCF (Chrome Cache File) ======= :

   else if
      (
            0xC3 == First50Ints[0] && 0xCA == First50Ints[1]
         && 0x04 == First50Ints[2] && 0xC1 == First50Ints[3]
      )
   {
      NewSuff = ".ccf";
   }

   // ====== CWS ======= :

   else if ( "CWS" == std::string(First50Chrs+0,3) )
   {
      NewSuff = ".cws";
   }

   // ====== FLAC ======= :

   else if ( "fLaC" == std::string(First50Chrs+0,4) )
   {
      NewSuff = ".flac";
   }

   // ======= FLV ======= :

   else if ('F' == First50Chrs[0] && 'L' == First50Chrs[1] && 'V' == First50Chrs[2])
   {
      NewSuff = ".flv";
   }

   // ====== GIF ======= :

   else if ( "GIF" == std::string(First50Chrs+0,3) )
   {
      NewSuff = ".gif";
      
   }

   // ====== FWS ======= :

   else if ( "FWS" == std::string(First50Chrs+0,3) )
   {
      NewSuff = ".fws";
   }

   // ====== JPG ======= :

   else if (255 == First50Ints[0] && 216 == First50Ints[1] && 255 == First50Ints[2])
   {
      NewSuff = ".jpg";
   }

   // ======= MP4 ======= :

   else if ( "ftypmp4" == std::string(First50Chrs+4,7) )
   {
      NewSuff = ".mp4";
   }

   // ====== PAR2 ======= :

   else if ( "PAR2" == std::string(First50Chrs+0,4) )
   {
      NewSuff = ".par2";
   }

   // ====== PDF ======= :

   else if ( "PDF" == std::string(First50Chrs+1,3) )
   {
      NewSuff = ".pdf";
   }

   // ====== PNG ======= :

   else if ( "PNG" == std::string(First50Chrs+1,3) )
   {
      NewSuff = ".png";
   }

   // ====== PK ======= :

   else if ( "PK" == std::string(First50Chrs+0,2) )
   {
      NewSuff = ".pk";
   }

   // ====== RAR ======= :

   else if ( "Rar" == std::string(First50Chrs+0,3) )
   {
      NewSuff = ".rar";
      
   }

   // ====== WAV ======= :

   else if ( "WAVEfmt" == std::string(First50Chrs+8,7) )
   {
      NewSuff = ".wav";
   }

   // ====== WMA ======= :

   else if
      (
             48 == First50Ints[ 0] &&  38 == First50Ints[ 1] && 178 == First50Ints[ 2]
         && 117 == First50Ints[ 3] && 142 == First50Ints[ 4] && 102 == First50Ints[ 5]
         && 207 == First50Ints[ 6] &&  17 == First50Ints[ 7] && 166 == First50Ints[ 8]
         && 217 == First50Ints[ 9] &&   0 == First50Ints[10] && 170 == First50Ints[11]
         &&   0 == First50Ints[12] &&  98 == First50Ints[13] && 206 == First50Ints[14]
         && 108 == First50Ints[15]
      )
   {
      NewSuff = ".wma";
   }

   // ~~~~~~~~~~~~~~~~~~~~ END FILE-TYPE-DETERMINATION SECTION: ~~~~~~~~~~~~~~~~~~~~



   // If NewSuff is still ".unk", this file is of unknown type:
   if (".unk" == NewSuff)
   {
      ++Stats.UnkCount;
      cout << "File " << OldName << " is of unknown type." << endl;
   }
   
   // Otherwise, we know the type:
   else
   {
      ++Stats.TypCount;
      cout << "File " << OldName << " is of known type." << endl;
   }

   // Now, make the new file name by tacking the new suffix onto the old prefix:
   NewName = Prefix + NewSuff;

   // If NewName is same as OldName, bypass this file:
   if (NewName == OldName)
   {
      ++Stats.BypCount;
      cout
         << "Bypassing file " << OldName << endl
         << "because new name is same as old." << endl;
   }

   // Else, attempt to rename the file:
   else
   {
      ++Stats.AttCount;
      cout << "Attempted rename #" << Stats.AttCount << ":" << endl;
      cout << OldName << " -> " << NewName << endl;
      bool bRenameSucceeded = rhdir::RenameFile(OldName, NewName);

      // If rename succeeded, increment success counter:
      if (bRenameSucceeded) 
      {
         ++Stats.RenCount;
         cout << "Rename succeeded!" << endl;
      }

      // Otherwise, increment failure counter:
      else
      {
         ++Stats.ErrCount;
         cout << "Rename failed!" << endl;
      }
   }

   // We be done, so skedaddle:
   return;

} // end ns_SetExt::ProcessCurrentFile()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Help()                                                                  //
//                                                                          //
//  Prints help.                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_SetExt::
Help
   (
      void
   )
{
   //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
   cout
                                                                                               << endl
   << "Welcome to set-extensions, Robbie Hatley's file name extension setting utility."        << endl
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
   << "This program examines every file in the current directory (and all of its"              << endl
   << "subdirectories, if a \"-r\" or \"--recurse\" switch is used), makes note of"            << endl
   << "the first 10 bytes of the file, determines if a known\"header\" pattern is"             << endl
   << "present, and corrects the file name extension if it doesn't match the header."          << endl
                                                                                               << endl;
   return;
} // end ns_SetExt::Help()

// end file set-extensions.cpp

