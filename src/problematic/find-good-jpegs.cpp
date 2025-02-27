
/************************************************************************************************************\
 * Program name:  find-good-jpegs
 * Description:   Finds and lists *.jpg files which DO begin with the 3 bytes "255, 216, 255".
 * File name:     find-good-jpegs.cpp
 * Source for:    find-good-jpegs.exe
 * Author:        Robbie Hatley
 * Date written:  Fri Oct 03, 2008
 * Edit History:
 *   Fri Oct 03, 2008 - Wrote it.
\************************************************************************************************************/

#include <iostream>
#include <iomanip>
#include <list>
#include <string>

#include <cstdlib>
#include <cstring>

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


namespace ns_FndGoodJpg
{
   using std::cin;
   using std::cout;
   using std::cerr;
   using std::endl;
   using std::setw;

   void         ProcessCurDir  (void);
   std::string  GetDamDir      (std::string FullCurrPath);
   void         Help           (void);

   unsigned long int DirCount; // Count of total directories processed.
   unsigned long int DgjCount; // Count of directories with undamaged jpeg files.
   unsigned long int FilCount; // Count of total files processed.
   unsigned long int GooCount; // Count of good jpeg files found.
   unsigned long int UnoCount; // Count of unopenable jpeg files found.
}



int
main
   (
      int    Beren,
      char*  Luthien[]
   )
{
   using namespace ns_FndGoodJpg;
   std::ios_base::sync_with_stdio();
   if (rhutil::HelpDecider(Beren, Luthien, Help)) return 0;
   if (!__file_exists("/Damaged")) mkdir("/Damaged",  S_IWUSR);
   rhdir::RecursionDecider(Beren, Luthien, ProcessCurDir);
   cout << "Processed " << setw(7) << DirCount << " directories."                     << endl;
   cout << "Found     " << setw(7) << DgjCount << " directories with good jpg files." << endl;
   cout << "Examined  " << setw(7) << FilCount << "   total    jpg files."            << endl;
   cout << "Found     " << setw(7) << GooCount << "   good     jpg files."            << endl;
   cout << "Found     " << setw(7) << UnoCount << " unopenable jpg files."            << endl;
   return 0;
}



void
ns_FndGoodJpg::
ProcessCurDir
   (
      void
   )
{
   // ABSTRACT:
   // This function announces the current directory, then finds and lists all "*.jpg" files
   // in the current directory which begin with "255, 216, 255".

   // Increment directory counter:
   ++DirCount;

   // Get the current path:
   std::string CurDir = rhdir::GetFullCurrPath();

   // Haven't found any good jpegs in this directory yet:
   bool FoundGoodJpegs = false;

   // Get a list of all "*.jpg" files in the current directory:
   std::list<rhdir::FileRecord> Files;
   rhdir::LoadFileList(Files, "*.jpg", 1, 1);

   // Create a standard input file stream:
   std::ifstream Fred;

   // Make an array of 3 chars and an array of 3 unsigned ints:
   char          First3Chrs [3] = {0};
   unsigned int  First3Ints [3] = {0};

   // Make a "current file is good" boolean variable:
   bool CurrFileIsGood = false;

   // Create an iterator for our file-record objects:
   std::list<rhdir::FileRecord>::iterator iter;

   // Iterate through the files, looking for good jpeg files:
   for ( iter = Files.begin(); iter != Files.end(); ++iter )
   {
      // Increment file counter:
      ++FilCount;

      // Attempt to open current file in binary, read-only mode:
      Fred.open(iter->name.c_str(), std::ios::in|std::ios::binary);

      // If open attempt failed, print error and go on to next file:
      if (!Fred.is_open())
      {
         cerr << "Error in find-good-jpegs.exe: can't open file "   << endl;
         cerr << iter->name                                         << endl;
         cerr << " for binary input.  Continuing to next file...."  << endl;
         ++UnoCount;
         continue;
      }

      // Read first 3 bytes into array FirstThreeChrs:
      Fred.read(First3Chrs, 10);

      // Close current file:
      Fred.close();

      // Convert each byte first to unsigned char to get 0 to 255 range,
      // then to unsigned int, so it will print as a number rather than a character:
      for ( int i = 0 ; i < 3 ; ++i )
      {
         First3Ints[i]
            = static_cast<unsigned int>(static_cast<unsigned char>(First3Chrs[i]));
      }

      // If debugging, print integer values of first 3 bytes:
      BLAT("First 3 bytes of file " << iter->name << " are " << endl \
      << std::setfill(' ') \
      << std::setw(4) << First3Ints[0] \
      << std::setw(4) << First3Ints[1] \
      << std::setw(4) << First3Ints[2] )

      // Mark file as "good" iff it starts with "255, 216, 255":
      CurrFileIsGood = (255 == First3Ints[0] && 216 == First3Ints[1] && 255 == First3Ints[2]);

      // If current file is good, list it:
      if (CurrFileIsGood)
      {
         // Annouce good file:
         cout << iter->path() << endl;

         // Increment good-file counter:
         ++GooCount;

         // If we get to here, this directory definitely has at least one good jpeg file:
         FoundGoodJpegs = true;

      } // end if (current file is good)

   } // end for (each file n Files)

   // If we found one or more good jpegs in this directory, increment DgjCount:
   if (FoundGoodJpegs) ++DgjCount;

   // Finished processing current directory:
   return;

} // end ProcessCurDir()


void
ns_FndGoodJpg::
Help
   (
      void
   )
{
   //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
   cout
   << "Welcome to find-good-jpegs, Robbie Hatley's good-jpeg-file-listing utility."            << endl
   << "This program finds and lists all \"*.jpg\" files in the current directory"              << endl
   << "(and all of its subdirectories, if a \"-r\" or \"--recurse\" switch is used)"           << endl
   << "which start with the bytes \"255, 216, 255\"."                                          << endl
                                                                                               << endl
   << "This version compiled at " << __TIME__ << " on " << __DATE__ << "."                     << endl
                                                                                               << endl
   << "Command-line syntax:"                                                                   << endl
   << "find-good-jpegs [switches]"                                                             << endl
                                                                                               << endl
   << "Switch:                          Meaning:"                                              << endl
   << "\"-h\" or \"--help\"             Print help and exit."                                  << endl
   << "\"-r\" or \"--recurse\"          Process all subdirectories."                           << endl;
   return;
} // end Help()


// end file find-good-jpegs.cpp
