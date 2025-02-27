
/************************************************************************************************************\
 * Program name:  Separate Jpeg Palimpsests
 * Description:   Finds all files in current directory (and all of its subdirectories if a "-r" or
 *                "--recurse" switch is used) which contain one of more occurrances of the "begin jpeg file"
 *                byte triplet 255,216,255 at locations other than the start of the file.  For each such
 *                file, this program will create palimpsest layer files consisting of the bytes from each
 *                255,216,255 triplet found (other than at the beginning of the file) and continuing to the
 *                end of the orgininal file.
 * File name:     separate-jpeg-palimpsests.cpp
 * Source for:    separate-jpeg-palimpsests.exe
 * Author:        Robbie Hatley
 * Date written:  Mon Oct 06, 2008
 * Edit History:
 *   Mon Oct 06, 2008 - Started writing it, but it's an extreme stubb.  (Doesn't split palimpsests yet.)
 *   Thu Mar 12, 2009 - Still an extreme stubb, due to me getting evicted from apartment on Nov 01, 2008.
 *   Sat Mar 21, 2009 - Completely re-wrote.  Now uses no global variables at all.  Uses an instance of
 *                      ProcessCurDirFunctor to process current directory.  Still extreme stubb, though.
 *                      Opens up directories and files, but doesn't yet slurp files into memory, look for
 *                      sigs, or write palimpsest layer separations.
 *   Sun Mar 22, 2009 - Completed the functionality.  Now separates jpeg palimpsest layers into separate
 *                      files in the same directory as the originals, with names consisting of:
 *                      original-prefix + ``` + layer-number + . + original-suffix.
 *                      Example: if "blat.jpg" has two layers, the layer files will be named
 *                      "blat```0001.jpg" and "blat```0002.jpg".
 *   Thu Mar 26, 2009 - Minor cleanup: help, these notes, and some refactoring.
 *   Fri Mar 27, 2009 - Changed the semantics to process even files which *DO* start with 255,216,255.
 *                      This will allow salvaging files which were written on top of an existing file,
 *                      at a positive offset, with directory entry retaining the original start point.
 *                      (I suspect Big-LBA disasters may cause exactly that kind of damage.)
 *                      Also corrected layer-count error.  (Count was always coming out 0; now fixed.)
 *                      Also changed semantics to operate on *ALL* types of files, not just jpg files,
 *                      because Big-LBA overwrites are blind and may write on top of any file.
\************************************************************************************************************/

#include <cstdlib>
#include <cstring>
#include <ctime>

#include <iostream>
#include <iomanip>
#include <list>
#include <string>
#include <fstream>
#include <sstream>

#include <unistd.h>
#include <sys/stat.h>

#undef NDEBUG
#include <assert.h>
#include <errno.h>

// Swap order of next two lines as desired to turn BLAT on or off:
#define BLAT_ENABLE
#undef  BLAT_ENABLE

#include "rhutil.hpp"
#include "rhdir.hpp"

namespace ns_Palimpsest
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
      uint32_t  FilCount;  // How many files did we process?
      uint32_t  UnoCount;  // How many files were unopenable?
      uint32_t  UnrCount;  // How many files were unreadable?
      uint32_t  UnwCount;  // How many files were unwritable?
      uint32_t  PalCount;  // How many palimpsest layers did we separate?
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

   void
   ProcessCurrentFile
   (
      Bools_t     const  &  Bools,
      Stats_t            &  Stats,
      FR          const  &  FilRec
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
   using namespace ns_Palimpsest;
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
ns_Palimpsest::
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
} // end ns_Palimpsest::ProcessFlags()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurDirFunctor::operator()                                        //
//                                                                          //
//  Processes current directory.                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void ns_Palimpsest::ProcessCurDirFunctor::operator() (void)
{
   BLAT("\nJust entered ProcessCurDir::operator().\n")

   // ABSTRACT:
   // This function finds all files in the current directory which contain instances of
   // the byte triplet 255,216,255 other than as the first 3 bytes of the file.
   // For each such file found, it calls function ProcessCurrentFile(), which creates
   // palimpsest layer files consisting of the bytes from each 255,216,255 triplet found
   // to the end of the original file.

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

   // Create wildcard, initialized to "*":
   std::string Wildcard = "*";

   // If there are arguments, construe first (zero-index) argument as wildcard:
   if (Arguments.size() > 0)
   {
      Wildcard = Arguments[0];
   }

   // Get a vector of file records all files in the current directory which
   // match the wildcard:
   rhdir::LoadFileList
   (
      FileList,  // File list.  (Actually, file vector, to be precise.)
      Wildcard,  // Wildcard.
      1,         // Files only (not directories).
      1          // Clear the file vector first.
   );

   BLAT("\nIn ProcessCurDirFunctor::operator().")
   BLAT("Finished building file list.")
   BLAT("File list size is " << FileList.size())
   BLAT("About to enter file-iteration for loop.\n")

   // Iterate through the files, looking for bad jpeg files:
   for ( VFCI iter = FileList.begin() ; iter != FileList.end() ; ++iter )
   {
      // Silently skip files with names containing "```";
      // don't even count them:
      if (std::string::npos != (iter->name).find("```")) continue;

      // If we get to here, name of current file contains the string "```",
      // so increment file counter:
      ++Stats.FilCount;

      BLAT("\nIn ProcessCurDir::operator(), in for loop.")
      BLAT("About to process file " << iter->name << "\n")

      // Process current file:
      ProcessCurrentFile(Bools, Stats, (*iter));

   } // end for (each file n Files)

   // Finished processing current directory:
   return;

} // end ns_Palimpsest::ProcessCurDir::operator()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// ProcessCurrentFile()                                                     //
// Processes the current file.                                              //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_Palimpsest::
ProcessCurrentFile
   (
      Bools_t  const  &  Bools,
      Stats_t         &  Stats,
      FR       const  &  FilRec
   )
{
   BLAT("\nAt top of ProcessCurrentFile().\n")

   // Announce processing current file:
   cout
      << endl
      << "Processing file #" << Stats.FilCount << ":" << endl
      << FilRec.name << endl;

   // Attempt to open current file in binary, read-only mode:
   static std::vector<unsigned char> Data;
   Data.reserve(2000000);
   std::ifstream Fred;
   Fred.open(FilRec.name.c_str(), std::ios::in|std::ios::binary);

   // If open attempt failed, print error and go on to next file:
   if (!Fred.is_open())
   {
      cerr
         << "File-open error: can't open file " << FilRec.name << " for binary input." << endl
         << "Continuing to next file." << endl;
      ++Stats.UnoCount;
      return;
   }

   char Byte;

   // Read file contents into memory:
   while (Fred)
   {
      Fred.get(Byte);
      if (Fred.eof()) break;
      if (Fred.fail() or Fred.bad())
      {
         cerr
            << endl
            << "File-input error: can't input from file " << FilRec.name << endl
            << "Continuing to next file." << endl;
         ++Stats.UnrCount;
         Fred.close();
         return;
      }
      Data.push_back(Byte);
   }

   // Close current file:
   Fred.close();

   BLAT("\nIn ProcessCurrentFile().")
   BLAT("Finished reading file " << FilRec.name)
   BLAT("Read " << Data.size() << " bytes.\n")

   // If there's less than 10,000 bytes of data in Data, this file cannot
   // contain multiple high-quality jpeg palimpset layers, so return:
   if (Data.size() < 10000)
   {
      cout
         << endl
         << "This file is too small to have high-quality jpeg palimpsest layers:" << endl
         << FilRec.name << endl
         << "Continuing to next file." << endl;
      return;
   }

   // Look for (255, 216, 255) signatures in Data, at starting positions other than the beginning
   // (hence we skip byte index 0), and continuing to byte index Data.size()-3; for each such
   // palimpsest-layer-beginning marker found, attempt to write a layer file:
   int LayerCount = 0; // Count of layer-write attempts.
   int WriteCount = 0; // Count of layer-write successes.
   for ( size_t i = 1 ; i < Data.size() - 2 ; ++i )
   {
      // If we don't see pattern (255,216,255) at current position,
      // increment index to next position and look again:
      if (255 != Data[i] or 216 != Data[i+1] or 255 != Data[i+2])
      {
         continue;
      }

      // If we get to here, we just found a palimpsest layer, so attempt to write it to a file:

      ++LayerCount; // Increment layer-write-attempt counter.
      std::ostringstream NewNameStream;
      NewNameStream
         << rhdir::GetPrefix(FilRec.name)
         << "```"
         << setfill('0') << setw(4) << LayerCount // Starts at 1 for first layer file.
         << rhdir::GetSuffix(FilRec.name);

      // Attempt to open an output file stream:
      std::ofstream Frank (NewNameStream.str().c_str(), std::ios_base::binary);

      // If attempt failed, alert, close, and continue:
      if (!Frank.good())
      {
         cerr
            << endl
            << "Error: Cannot open output file " << NewNameStream.str().c_str() << endl
            << "Continuing to look for palimpsest layers in current file."  << endl;
         continue;
      }

      // Otherwise, announce that we're about to write to new file:
      else
      {
         cout
            << endl
            << "Found palimpsest layer at index " << i << endl
            << "Writing layer to file " << NewNameStream.str() << endl;
      }

      BLAT("\nIn ProcessCurrentFile().")
      BLAT("About to write to file " << NewNameStream.str())
      BLAT("Frank.good()   = " << Frank.good())
      BLAT("Frank.bad()    = " << Frank.bad())
      BLAT("Frank.fail()   = " << Frank.fail())
      BLAT("Frank.eof()    = " << Frank.eof() << "\n")

      // Attempt to write the bytes to the file:
      for ( size_t j = i ; Frank.good() && j < Data.size() ; ++j )
      {
         Frank.put(static_cast<char>(Data[j]));
      }

      // If the stream is still good, the write succeeded, so increment counters and annouce success:
      if (Frank.good())
      {
         ++Stats.PalCount;  // Increment count of total layers written for this directory tree.
         ++WriteCount;      // Increment count of layers written for current original jpg file.
         cout
            << "Successfully wrote "
            << Data.size() - i
            << " bytes to layer file "
            << NewNameStream.str()
            << endl;
      }

      // Otherwise, announce failure:
      else
      {
         cerr
            << "Error while trying to write bytes to layer file "
            << NewNameStream.str()
            << endl;
      }

      // Close the file:
      Frank.close();
   }

   cout
      << endl
      << "Finished processing file " << FilRec.name << endl
      << "Wrote " << WriteCount << " palimpsest layer separations for this file." << endl;

   BLAT("\nAt bottom of ProcessCurrentFile().")
   BLAT("About to clear Data vector and return.\n")

   Data.clear();

   return;
} // end ns_Palimpsest::ProcessCurrentFile()


void ns_Palimpsest::Stats_t::PrintStats (void)
{
   cout
      << endl
      << "Finished separate-jepeg-palimpsests session.\n"
      << "Summary data follows:\n"
      << "Processed " << setw(7) << DirCount << " directories.\n"
      << "Examined  " << setw(7) << FilCount << "   total    jpg files.\n"
      << "Found     " << setw(7) << UnoCount << " unopenable jpg files.\n"
      << "Found     " << setw(7) << UnrCount << " unreadable jpg files.\n"
      << "Found     " << setw(7) << UnwCount << " unwritable jpg files.\n"
      << "Wrote     " << setw(7) << PalCount << " jpeg palimpsest layer separations."
      << endl;
}


void ns_Palimpsest::Help (void)
{
   //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
   cout
   << "Welcome to separate-jpeg-palimpsests by Robbie Hatley."                                 << endl
   << "This version compiled at " << __TIME__ << " on " << __DATE__ << "."                     << endl
                                                                                               << endl
   << "This program looks for files which contain occurances of the 3-byte sequence"           << endl
   << "255,216,255 at locations other than the beginning of the file.  For each such"          << endl
   << "file found, it separates the layers of the palimpsest into separate files in"           << endl
   << "the same directory, with file names consisting of the original prefix"                  << endl
   << "followed by \"```\" followed by a 4-digit layer number folowed by a dot followed"       << endl
   << "by the original suffix.  For example, if file \"blat.jpg\" is found to have two"        << endl
   << "palimpsest layers, the two layer files will be named \"blat```0001.jpg\" and"           << endl
   << "\"blat```0002.jpg\"."                                                                   << endl
                                                                                               << endl
   << "This program is especially useful in recovering from Big-LBA disasters, in which"       << endl
   << "a Win2K user inadvertantly writes to the upper (>137GB) portion of a very-large"        << endl
   << "hard disk without first going to this registry branch:"                                 << endl
   << "HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Services/atapi/Parameters"                  << endl
   << "and changing parameter \"EnableBigLba\" from 0 to 1.  If this isn't done,"              << endl
   << "data the user attempts to write to the upper part of the disk is actually"              << endl
   << "written to the lower part of the disk, ON TOP OF EXISTING DATA, DESTROYING IT."         << endl
   << "Needless to say, this is disastrous.  It can destroy data and/or programs and/or"       << endl
   << "the operating system.  At worst, it may be simpler to throw away the computer"          << endl
   << "and buy a new one than to try to fix the damage.  (It tends to be unfixable.)"          << endl
   << "Suicide is always a viable option at that point.  Since this isn't exactly"             << endl
   << "intuitive or self-evident (!!!), big hard disks (over 137GB) are a disaster"            << endl
   << "waiting to happen in Win-2K.  (I believe this has been fixed in Win-XP.)"               << endl
                                                                                               << endl
   << "But if the damage is confined to data files, THIS program can at least help"            << endl
   << "you to recover some of your jpeg files.  Files which were overwritten are gone"         << endl
   << "forever, BUT THE FILES WHICH WERE WRITTEN ON TOP OF THEM MAY BE RECOVERED!!!"           << endl
   << "This program basically looks for *.jpg files which were written on top of other"        << endl
   << "files, without altering the original files' directory entries.  The bottom files"       << endl
   << "got destroyed, but this program can recover any *.jpg files which were written"         << endl
   << "on top of them, by looking for the tell-tale 255,216,255 \"begin jpg file\""            << endl
   << "signature, and extracting the bytes from that signature to the end of the"              << endl
   << "overwritten file.  If the jpg file was smaller than the overwritten file, it"           << endl
   << "may be possible to recover the entire file.  Even if the top file was, itself,"         << endl
   << "partially overwritten by another file (typical in Big-LBA disasters),"                  << endl
   << "the upper portion of the image can usually be recovered."                               << endl
                                                                                               << endl
   << "To process only files matching a given wildcard, simply put the desired"                << endl
   << "wildcard on the command line, either before or after any switches."                     << endl
   << "Example: \"separate-jpeg-palimpsests q*.jpg -r\" will process all jpg"                  << endl
   << "files beginning with the letter 'q', in all subdirectories."                            << endl
                                                                                               << endl
   << "Command-line syntax:"                                                                   << endl
                                                                                               << endl
   << "To just print help and exit:"                                                           << endl
   << "separate-jpeg-palimpsests -h|--help"                                                    << endl
                                                                                               << endl
   << "To process current directory only:"                                                     << endl
   << "separate-jpeg-palimpsests [wildcard]"                                                   << endl
                                                                                               << endl
   << "To process entire branch:"                                                              << endl
   << "separate-jpeg-palimpsests -r|--recurse [wildcard]"                                      << endl
                                                                                               << endl
   << "To write a log file while processing:"                                                  << endl
   << "redir -o jpeg-palimp-log.txt -eo separate-jpeg-palimpsests [-r] [wildcard]"             << endl;

   return;
} // end ns_Palimpsest::Help()

// end of file "separate-jpeg-palimpsests.cpp"

