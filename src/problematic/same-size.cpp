
/************************************************************************************************************\
 * File name:      same-size.cpp
 * Source for:     same-size.exe
 * Program Name:   Same Size
 * Description:    Alerts user to existence of files in a directory with exactly same size.
 * Author:         Robbie Hatley
 * Date written:   Friday August 17, 2012
 * Inputs:         An optional command line argument, which must be one of these switches:
 *                 "-r" or "--recurse" to recurse subdirectories
 *                 "-h" or "--help" for help
 * Outputs:        Writes to stdout.  (Can be redirected to a file.)
 * Dependencies:
 *    rhutil.h, rhdir.h, librh.a, unistd.h (djgpp compiler-dependent header; see www.delorie.com).
 * To make:
 *    Compile with djgpp (see www.delorie.com) and link with rhutil.o and rhdir.o in library librh.a .
 * Edit history:
 *    Fri Aug 17, 2012 - Wrote it, based heavily on "Dedup Files".
\************************************************************************************************************/

#include <iostream>
#include <string>

#include "rhutil.hpp"
#include "rhdir.hpp"

namespace ns_rhdedup
{
   using std::cout;
   using std::cerr;
   using std::endl;
   using std::setw;

   typedef  std::vector<std::string>  VS;
   typedef  rhdir::FileRecord         FR;
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
      uint32_t  BypCount;  // Count of files bypassed.
      uint32_t  ErrCount;  // Count of errors encountered.
      uint32_t  ProCount;  // Count of files successfully processed.
      void PrintStats (void)
      {
         cout
                                                                        << endl
            << "Finished processing files in this tree."                << endl
            << "Directories processed:        " << setw(7) << DirCount  << endl
            << "Files examined:               " << setw(7) << FilCount  << endl
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
               Stats_t            &  Stats_
            )
            : Settings(Settings_), Arguments(Arguments_), Stats(Stats_)
            {}
         void operator()(void); // defined below
      private:
         Settings_t  const  &  Settings;
         VS          const  &  Arguments;
         Stats_t            &  Stats;     // Non-const so function can increment stats counters.
   };

   // For programs that process individual files, this next function is "the function that does
   // all the real work of the program".  This may be just gleaning info from a file, or altering
   // the contents of a file, or perhaps renaming it.  This function is intended to be called
   // from a for loop in ProcessCurDirFunctor:

   void Help (void);

} // End namespace ns_rhdedup


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  main()                                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

int main (int Beren, char * Luthien[])
{
   // Set main namespace we're using:
   using namespace ns_rhdedup;

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

   // Process arguments (set settings based on arguments; this can be deleted if not using
   // arguments to set settings):
   ProcessArguments(Arguments, Settings);

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
   ProcessCurDirFunctor ProcessCurDir (Settings, Arguments, Stats);

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
}


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessFlags()                                                          //
//                                                                          //
//  Sets program settings based on Flags.                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_rhdedup::
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

   BLAT("About to return from ProcessFlags.\n")
   return;
} // end ns_rhdedup::ProcessFlags()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessArguments()                                                      //
//                                                                          //
//  Sets program settings based on Arguments.                               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_rhdedup::
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
} // end ns_rhdedup::ProcessArguments()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurDirFunctor::operator()                                        //
//                                                                          //
//  Processes current directory.                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void ns_rhdedup::ProcessCurDirFunctor::operator() (void)
{
   BLAT("\nJust entered ProcessCurDirFunctor::operator().\n")

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

   // Convert any tilde ('~') characters in file names in current directory to underscore ('_') characters:
   rhdir::UnTilde();

   // Make a multimap of file records, keyed by size:
   std::multimap<size_t, rhdir::FileRecord> FileMap;

   // Get iterators to the elements of FileMap:
   std::multimap<size_t, rhdir::FileRecord>::iterator i, j, Last;

   // Load sizes and file records of all files in current directory into a multimap<size_t, FileRecord>,
   // so that the files are sorted and grouped in order of increasing size:
   rhdir::LoadFileMap(FileMap);

   // Go through map, finding all same-size file groups and alerting user:
   for (i = FileMap.begin() ; i != FileMap.end() ; i = FileMap.upper_bound(i->first))
   {
      // for each file (if any) in this size group after i and same size as i:
      for (j = i, ++j; j != FileMap.end() and j->first == i->first ; ++j)
      {
         // If we get to here, file j is the same size as file i, so announce this fact:
         cout << j->second.name << " is same size as " << i->second.name << endl;
      }
   }

   Stats.FilCount += FileMap.size();

   BLAT("\nAt end of ProcessCurDirFunctor::operator(), about to return.\n")
   return;
} // End ProcessCurrentDirectory()


/************************************************************************************************************\
 * Help()                                                                                                   *
 * Print help.                                                                                              *
\************************************************************************************************************/
void ns_rhdedup::Help(void)
{
   cout
   << "Welcome to same-size.exe, Robbie Hatley's same-size file finder."               << endl
   << "This version was compiled at " << __TIME__ << " on " << __DATE__ << "."         << endl
                                                                                       << endl
   << "same-size.exe finds all same-size file groups in the current directory."        << endl
                                                                                       << endl
   << "Use an -r or --recurse switch to process all subdirectories."                   << endl
   << "Use an -h or --help    switch to print these instructions."                     << endl;
   return;
}
