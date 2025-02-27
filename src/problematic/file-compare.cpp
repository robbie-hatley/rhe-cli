/************************************************************************************************************\
 * Program name:  FileCompare
 * Description:   Compares two files, and state whether or not they're identical.
 * File name:     file-compare.cpp
 * Executable:    file-compare.exe
 * Author:        Robbie Hatley
 * Date written:  Sat. Apr. 24, 2004
 * Edit history:
 *    Sat Apr 24, 2004 - Started writing the damn thing.
 *    Wed Dec 01, 2004 - Added instructions.
 *    Mon Sep 12, 2004 - Completely re-wrote it.  Now gives printouts of byte differences in hex.
 * Inputs:        Two command-line arguments, which must be valid paths to existing files.
 * Outputs:       Prints "Files are identical" or "Files are different"; also prints-out all byte differences
 *                and extra bytes in hex.
 * To make:       Link with rhutil.o and rhdir.o in librh.a.
\************************************************************************************************************/

// Use asserts?
#undef NDEBUG
//#define NDEBUG
#include <assert.h>

#include <iostream>
#include <iomanip>
#include <string>
#include <vector>

#include <dir.h>

// define or undef BLAT_ENABLE here to enable/disable debug output macro
// "BLAT", located in rhutil.h (obviously, this line must come BEFORE
// the line that includes rhutil.h):

//#define BLAT_ENABLE
#undef BLAT_ENABLE

#include "rhutil.hpp"
#include "rhdir.hpp"

namespace ns_FC
{
   using std::cout;
   using std::cerr;
   using std::endl;
   using std::left;
   using std::right;
   using std::internal;
   using std::setw;
   using std::dec;
   using std::hex;
   using std::showbase;
   using std::noshowbase;
   using std::setprecision;
   using std::setfill;
   using std::flush;

   struct Difference
   {
      Difference() : Index(777), Byte1(888), Byte2(999) {}
      long     int  Index;
      unsigned int  Byte1;
      unsigned int  Byte2;
   };

   void
   GetFileNames
      (
         int                const      Rose,
         char                      **  Mums,
         std::string               &   Name1,
         std::string               &   Name2
      );

   void
   GetFileRecords
      (
         std::string        const  &  Name1,
         std::string        const  &  Name2,
         rhdir::FileRecord         &  R1,
         rhdir::FileRecord         &  R2
      );

   void
   CompareFiles
      (
         rhdir::FileRecord  const  &  R1,
         rhdir::FileRecord  const  &  R2
      );

   void
   Help
      (
         void
      );
}


int main(int Roses, char** Mums)
{
   using namespace ns_FC;

   BLAT("Just entered main(), about to run HelpDecider().")

   // If user requests help, print help and exit:
   if (rhutil::HelpDecider(Roses, Mums, Help)) return 777;

   BLAT("Finished running HelpDecider(); about to run GetFileNames().")

   // Get file names:
   std::string Name1, Name2;
   GetFileNames(Roses, Mums, Name1, Name2);

   BLAT("Finished running GetFileNames(); about to run GetFileRecords().")

   // Get file records:
   rhdir::FileRecord R1, R2;
   GetFileRecords(Name1, Name2, R1, R2);

   BLAT("Finished running GetFileRecords(); about to run CompareFiles().")

   // Compare these two files and print the results:
   CompareFiles(R1, R2);

   BLAT("Finished running CompareFiles(); about to return 0 from main().")

   return 0;
}


void
ns_FC::
GetFileNames
   (
      int          const      Rose,
      char                **  Mums,
      std::string         &   Name1,
      std::string         &   Name2
   )
{
   // Bail if wrong number of arguments:
   if (3 != Rose)
   {
      cerr << "Error: file-compare.exe takes 2 arguments!" << endl;
      exit(666);
   }

   // Get file names:
   Name1 = rhutil::StripLeadingAndTrailingSpaces(Mums[1]);
   Name2 = rhutil::StripLeadingAndTrailingSpaces(Mums[2]);


   // BLAT RH 2006-06-26: I commented-out the following, because it was
   // preventing valid automatically-generated MSDOS 8x3 file names from being
   // given as arguments to this program, as those often contain contain tildes,
   // which are considered "invalid file name characters" by
   // rhdir::FileNameIsInvalid().

   // // If these names are invalid, print error message and bail:
   // if (rhdir::FileNameIsInvalid(Name1) || rhdir::FileNameIsInvalid(Name2))
   // {
   //    cerr
   //       << endl
   //       << "Error: one or both of the file names given are invalid!" << endl
   //       << "Please simplify the file names to remove troublesome characters," << endl
   //       << "either manually or with simplify-file-names.exe ." << endl;
   //    exit(666);
   // }

   return;
}


void
ns_FC::
GetFileRecords
   (
      std::string        const  &  Name1,
      std::string        const  &  Name2,
      rhdir::FileRecord         &  R1,
      rhdir::FileRecord         &  R2
   )
{
   // Try to find files in directory:
   ffblk FileBlock1, FileBlock2;
   int Flags = FA_RDONLY | FA_HIDDEN | FA_SYSTEM | FA_ARCH;
   bool bExists1 = !static_cast<bool>(findfirst(Name1.c_str(), &FileBlock1, Flags));
   bool bExists2 = !static_cast<bool>(findfirst(Name2.c_str(), &FileBlock2, Flags));

   // If either file doesn't actually exist, print error message and bail:
   if (!bExists1 || !bExists2)
   {
      cerr
         << endl
         << "Error: one or both of the files names given do not exist!" << endl;
      exit(666);
   }

   // Get curr. dir.:
   // ( WOMBAT : This assumes both files are in current directory!  If one or both
   // are not, unknown what would happen.  Probably nothing good! )
   std::string CurrDir ( rhdir::GetFullCurrPath() );

   // If we get to here, both files exist, so put their info in R1 and R2:
   R1 = rhdir::FileRecord(FileBlock1, CurrDir);
   R2 = rhdir::FileRecord(FileBlock2, CurrDir);

   return;
}


void
ns_FC::
CompareFiles
   (
      rhdir::FileRecord const & R1,
      rhdir::FileRecord const & R2
   )

{

   BLAT("Just entered CompareFiles().")

   // Attempt to open the files:
   std::ifstream F1 (R1.name.c_str(), std::ios_base::binary);
   std::ifstream F2 (R2.name.c_str(), std::ios_base::binary);
   if (!F1)
   {
      cerr << "File IO error: can't open file " << R1.name << " for input." << endl;
      exit(666);
   }
   if (!F2)
   {
      cerr << "File IO error: can't open file " << R2.name << " for input." << endl;
      exit(666);
   }

   // If we get here, they're both now open, so let's compare them byte-by-byte:

   char      F1Byte         = '\0';
   char      F2Byte         = '\0';
   long int  ByteCount      = 0;
   int       DiffCount      = 0;
   int       ExtraCount1    = 0;
   int       ExtraCount2    = 0;

   BLAT("In CompareFiles(); about to allocate vector DiffBytes.")

   std::vector<ns_FC::Difference> DiffBytes   (R1.size < R2.size ? R1.size + 10 : R2.size + 10);

   BLAT("In CompareFiles(); finished allocating vector DiffBytes.")
   BLAT("In CompareFiles(); about to allocate   vector ExtraBytes1.")

   std::vector<ns_FC::Difference> ExtraBytes1 (R1.size > R2.size ? R1.size - R2.size + 10 : 0);

   BLAT("In CompareFiles(); finished allocating vector ExtraBytes1.")
   BLAT("In CompareFiles(); about to allocate   vector ExtraBytes2.")

   std::vector<ns_FC::Difference> ExtraBytes2 (R2.size > R1.size ? R2.size - R1.size + 10 : 0);

   BLAT("In CompareFiles(); finished allocating vector ExtraBytes2.")

   while (42)
   {
      if (!F1.eof()) {F1.get(F1Byte);}
      if (StreamIsBad(F1))
      {
         cerr << "File IO error while reading file " << R1.name << endl;
         exit(666);
      }

      if (!F2.eof()) {F2.get(F2Byte);}
      if (StreamIsBad(F2))
      {
         cerr << "File IO error while reading file " << R2.name << endl;
         exit(666);
      }

      if (F1.eof() && F2.eof()) // If both files are now eof,
      {
         break;                 // break out of while loop.
      }

      // If we get to here, at least one of our two attempted IO operations succeeded, so increment byte
      // counter to indicate we advanced one position in the file(s):
      ++ByteCount;

      // If neither stream has gone eof yet, let's compare the F1Byte and F2Byte we just read.
      // If the two bytes are inequal, increment difference counter, record the differing bytes,
      // and continue looping:
      if (!F1.eof() && !F2.eof())
      {
         if (F1Byte != F2Byte)
         {
            ++DiffCount;
            DiffBytes[DiffCount - 1].Index = ByteCount - 1;
            DiffBytes[DiffCount - 1].Byte1 = (unsigned int)(unsigned char)(F1Byte);
            DiffBytes[DiffCount - 1].Byte2 = (unsigned int)(unsigned char)(F2Byte);
         }
      }

      // If only F1 is still good, record the extra F1 byte and continue looping:
      else if (!F1.eof() && F2.eof())
      {
         ++ExtraCount1;
         ExtraBytes1[ExtraCount1 - 1].Index = ByteCount - 1;
         ExtraBytes1[ExtraCount1 - 1].Byte1 = (unsigned int)(unsigned char)(F1Byte);
         continue;
      }

      // If only F2 is still good, record the extra F2 byte and continue looping:
      else if (F1.eof() && !F2.eof())
      {
         ++ExtraCount2;
         ExtraBytes2[ExtraCount2 - 1].Index = ByteCount - 1;
         ExtraBytes2[ExtraCount2 - 1].Byte2 = (unsigned int)(unsigned char)(F2Byte);
         continue;
      }
   } // End while (42).
   F1.close();
   F2.close();

   if
   (
      0 == DiffCount
      &&
      0 == ExtraCount1
      &&
      0 == ExtraCount2
   )
   {
      cout << "Files are identical." << endl;
      return;
   }
   else
   {
      cout << "Files are different." << endl;
   }

   if (DiffCount > 0)
   {
      cout << "Files have " << DiffCount << " byte differences in the parts which overlap." << endl;
      cout << "Table of byte differences follows."                                          << endl
                                                                                            << endl
           << "     Byte     First   Second  "                                              << endl
           << "     Index    File    File    "                                              << endl
                                                                                            << endl;
      for (int i = 0; i < DiffCount; ++i)
      {
         cout << setw(10) << right    << setfill(' ') << dec << noshowbase << DiffBytes[i].Index
              << "    "
              << setw(4)  << internal << setfill('0') << hex << showbase   << DiffBytes[i].Byte1
              << "    "
              << setw(4)  << internal << setfill('0') << hex << showbase   << DiffBytes[i].Byte2 << '\n';
      }
      cout << dec << flush;
   }

   if (ExtraCount1 > 0)
   {
      cout << "First file has " << ExtraCount1 << " more bytes than second file."           << endl;
      cout << "Table of extra bytes follows."                                               << endl
                                                                                            << endl
           << "     Byte     Byte    "                                                      << endl
           << "     Index    Value   "                                                      << endl
                                                                                            << endl;
      for (int i = 0; i < ExtraCount1; ++i)
      {
         cout << setw(10) << right    << setfill(' ') << dec << noshowbase << ExtraBytes1[i].Index
              << "    "
              << setw(4)  << internal << setfill('0') << hex << showbase   << ExtraBytes1[i].Byte1 << '\n';
      }
      cout << dec << flush;
   }

   if (ExtraCount2 > 0)
   {
      cout << "Second file has " << ExtraCount2 << " more bytes than first file."           << endl;
      cout << "Table of byte differences follows."                                          << endl
                                                                                            << endl
           << "     Byte     Byte    "                                                      << endl
           << "     Index    Value   "                                                      << endl
                                                                                            << endl;
      for (int i = 0; i < ExtraCount2; ++i)
      {
         cout << setw(10) << right    << setfill(' ') << dec << noshowbase << ExtraBytes2[i].Index
              << "    "
              << setw(4)  << internal << setfill('0') << hex << showbase   << ExtraBytes2[i].Byte2 << '\n';
      }
      cout << dec << flush;
   }

   BLAT("At end of CompareFiles(); about to return.")

   return;
}


void
ns_FC::
Help
   (
      void
   )
{
   cout <<
   "Welcome to file-compare.exe , Robbie Hatley's nifty file-difference finder.\n\n";
   cout <<
   "This version was compiled at " << __TIME__ << " on " << __DATE__ << ".\n\n";
   cout <<
   "Switches:\n"
   "If a -h or --help switch is used, then file-compare.exe will print these\n"
   "instructions and exit without comparing any files; any other command-line\n"
   "arguments will be ignored.  No switches other than -h or --help are recognized.\n\n";
   cout <<
   "Arguments:\n"
   "file-compare.exe takes two arguments, which much be valid paths to existing\n"
   "files.  file-compare.exe will then compare these two files and tell you whether\n"
   "or not they are identical.  If differences are found, file-compare.exe will\n"
   "present the differences as byte pairs (in hex) keyed by byte index (in decimal).\n\n";
   cout <<
   "Extra Bytes:\n"
   "If one file is larger than the other, file-compare.exe will also present the\n"
   "first 1000 extra bytes (in hex), keyed by byte index (in decimal).\n";
   cout << flush;
   return;
}
