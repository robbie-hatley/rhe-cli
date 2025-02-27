
/****************************************************************************\
 * Program name:  UnDamage
 * File name:     undamage.cpp
 * Source for:    undamage.exe
 * Description:
 * Author:        Robbie Hatley
 * Date written:
 * Inputs:
 * Outputs:
 * Notes:
 * To make:
 * Edit History:
 *   Sun May 17, 2009 - Wrote it.
\****************************************************************************/

// Include old C headers:
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cctype>
#include <cmath>
#include <ctime>

// Include new C++ headers:
#include <iostream>
#include <iomanip>
#include <fstream>
#include <vector>
#include <list>
#include <deque>
#include <string>
#include <algorithm>
#include <functional>
#include <typeinfo>
#include <new>

// Include platform-dependent headers:
#include <conio.h>
#include <unistd.h>
#include <dir.h>

// Use assert?  (Undefine "NDEBUG" to use asserts; define it to NOT use them.)
#define NDEBUG
#undef  NDEBUG
#include <assert.h>
#include <errno.h>

// Use BLAT?  (Define "BLAT_ENABLE" to use BLAT; undefine it to NOT use BLAT.)
#define BLAT_ENABLE
#undef  BLAT_ENABLE

// Include personal library headers:
#include "rhutil.hpp"
#include "rhdir.hpp"
#include "rhmath.hpp"
#include "rhbitmap.hpp"
#include "rhncgraphics.hpp"

namespace ns_MyNameSpace
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

   struct Bools_t     // program boolean settings
   {
      bool bHelp;     // Did user ask for help?
      bool bRecurse;  // Walk directory tree downward from current node?
   };

   struct Stats_t     // program run-time statistics
   {
      uint32_t  DirCount;  // Count of directories processed.
      uint32_t  FilCount;  // Count of files examined.
      uint32_t  BypCount;  // Count of files bypassed.
      uint32_t  ErrCount;  // Count of errors encountered.
      uint32_t  ProCount;  // Count of files successfully processed.
      void PrintStats (void)
      {
         cout
                                                                         << endl
            << "Finished processing files in this tree."                 << endl
            << "Directories processed:         " << setw(5) << DirCount  << endl
            << "Files examined:                " << setw(5) << FilCount  << endl
            << "Errors encountered:            " << setw(5) << ErrCount  << endl
            << "Files successfully processed:  " << setw(5) << ProCount  << endl
                                                                         << endl;
      }
   };

   void
   ProcessFlags
   (
      VS           const  &  Flags,
      Bools_t             &  Bools
   );

   class ProcessCurDirFunctor
   {
      public:
         ProcessCurDirFunctor
            (
               Bools_t  const  &  Bools_,
               VS       const  &  Arguments_,
               Stats_t         &  Stats_,
               VFR             &  FileList_
            )
            : Bools(Bools_), Arguments(Arguments_), Stats(Stats_), FileList(FileList_)
            {}
         void operator()(void); // defined below
      private:
         Bools_t  const  &  Bools;
         VS       const  &  Arguments;
         Stats_t         &  Stats;
         VFR             &  FileList;
   };

   void
   ProcessCurrentFile
   (
      Bools_t  const  &  Bools,
      VS       const  &  Arguments,
      Stats_t         &  Stats,
      VFR      const  &  FileList,
      FR       const  &  FilRec
   );

   void Help (void);

} // end namespace ns_MyNameSpace


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  main()                                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

int main (int Beren, char * Luthien[])
{
   using namespace ns_MyNameSpace;
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
   static VFR FileList;
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
ns_MyNameSpace::
ProcessFlags
   (
      VS       const  &  Flags,
      Bools_t         &  Bools
   )
{
   BLAT("\nJust entered ProcessFlags().  About to set Bools.\n")

   // Use InVec from rhutil:
   using rhutil::InVec;

   Bools.bHelp    =      InVec(Flags, "-h") or InVec(Flags, "--help"     ) ;
   Bools.bRecurse = not (InVec(Flags, "-n") or InVec(Flags, "--norecurse"));

   BLAT("About to return from ProcessFlags.\n")
   return;
} // end ns_MyNameSpace::ProcessFlags()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurDirFunctor::operator()                                        //
//                                                                          //
//  Processes current directory.                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void ns_MyNameSpace::ProcessCurDirFunctor::operator() (void)
{
   // ABSTRACT:
   // The idea of this function is
   // to twaddle all turnips in
   // the current directory.

   BLAT("\nJust entered ProcessCurDir::operator().\n")

   // Get current directory:
   std::string CurDir = rhdir::GetFullCurrPath();

   // If this directory's name does not end with "Damaged",
   // skip this directory.  Don't even count it.
   if (CurDir.length() - 7 != CurDir.rfind("Damaged"))
   {
      return;
   }

   // Increment directory counter:
   ++Stats.DirCount;

   // Annouce processing current directory:
   cout
      << "\n"
      << "=================================================================\n"
      << "Directory #" << Stats.DirCount << ":\n"
      << CurDir << "\n"
      << endl;

   // Get vector of file records for all files in current directory which match
   // the wildcards given by the command-line arguments, if any.
   // If no arguments were given, get all files:
   FileList.clear();
   std::string Wildcard;
   if (Arguments.size() > 0)
   {
      for (VSCI i = Arguments.begin(); i != Arguments.end(); ++i)
      {
         Wildcard = *i;
         rhdir::LoadFileList
         (
            FileList,  // Name of container to load.
            Wildcard,  // File-name wildcard.
            1,         // Files only (not dirs).
            2          // Append to list without clearing.
         );
      }
   }
   else
   {
      rhdir::LoadFileList(FileList); // Get all files.
   }

   BLAT("\nIn ProcessCurDirFunctor::operator().")
   BLAT("Finished building file list.")
   BLAT("File list size is " << FileList.size())
   BLAT("About to enter file-iteration for loop.\n")

   /* --------------------------------------------------------------- */
   /*  Iterate through the files, performing xxxxx for each file:     */
   /* --------------------------------------------------------------- */
   for ( VFRI  i = FileList.begin() ; i != FileList.end() ; ++i )
   {
      ++Stats.FilCount;
      rename(i->name.c_str(), ("../" + i->name).c_str());
      ++Stats.ProCount;
   } // end for (each file in FileList)
   return;
} // end ns_MyNameSpace::ProcessCurDirFunctor::operator()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurrentFile()                                                    //
//                                                                          //
//  Processes current file.                                                 //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_MyNameSpace::
ProcessCurrentFile
   (
      Bools_t  const  &  Bools,
      VS       const  &  Arguments,
      Stats_t         &  Stats,
      VFR      const  &  FileList,
      FR       const  &  FilRec
   )
{
   // Do something here with the file who's record is in FilRec;
   // this may or may-not modify the file:
   ; // Do something.
   ; // Do something else.
   ; // Do some more stuff.
   ; // Finish doing stuff.
   return;
} // end ns_MyNameSpace::ProcessCurrentFile()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Help()                                                                  //
//                                                                          //
//  Prints help.                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_MyNameSpace::
Help
   (
      void
   )
{
   //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
   cout
   << "Welcome to MyFancyProgram, Robbie Hatley's turnip-twaddling utility."                   << endl
                                                                                               << endl
   << "This version compiled at " << __TIME__ << " on " << __DATE__ << "."                     << endl
                                                                                               << endl
   << "If this had been an actual program, real help would have been given here,"              << endl
   << "including a description of the program, what it does, and how it does it."              << endl
   << "But since this isn't, it wasn't."                                                       << endl
                                                                                               << endl
   << "Command-line syntax:"                                                                   << endl
                                                                                               << endl
   << "To print this help and exit:"                                                           << endl
   << "MyFancyProgram -h|--help"                                                               << endl
                                                                                               << endl
   << "To [insert brief description of primary function of program here]:"                     << endl
   << "MyFancyProgram [switches] [arguments] < InputFile > OutputFile"                         << endl
                                                                                               << endl
   << "Switch:                      Meaning:"                                                  << endl
   << "\"-h\" or \"--help\"             Print help and exit."                                  << endl
   << "\"-r\" or \"--recurse\"          Process all subdirectories."                           << endl;
   return;
} // end ns_MyNameSpace::Help()

// end file template.cpp
