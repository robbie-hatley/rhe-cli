
/************************************************************************************************************\
 * Program name:  Flatten Directory Tree
 * File name:     flatten-directory-tree.cpp
 * Source for:    flatten-directory-tree.exe
 * DKM macro:     fdt
 * Description:   Prints a list of all subdirectories of current directory, sorted by subdirectory name,
 *                with name on left, followed by a tab character, followed by full path.
 * Author:        Robbie Hatley
 * Date written:  Mon Jul 25, 2011
 * Inputs:        Command line and current directory tree.
 * Outputs:       Writes text to stdout.
 * Notes:         At least in first draft, works by traversing tree and appending (child, parent) info for
 *                each subdir to a list of strings, then sorting and printing the list.
 * To make:       Link with modules rhutil and rhdir in library "librh.a" in folder "E:\RHE\lib".
 * Edit History:
 *   Mon Jul 25 - Wrote it.
\************************************************************************************************************/

#include <iostream>
#include <vector>
#include <list>
#include <string>
#include <sstream>

// Use assert?  (Undefine "NDEBUG" to use asserts; define it to NOT use them.)
#undef  NDEBUG
#define NDEBUG
#include <assert.h>
#include <errno.h>

// Use BLAT?  (Define "BLAT_ENABLE" to use BLAT; undefine it to NOT use BLAT.)
#define BLAT_ENABLE
#undef  BLAT_ENABLE

// Include personal library headers:
#include "rhutil.hpp"
#include "rhdir.hpp"

namespace ns_FDT
{
   using std::cout;
   using std::endl;
   using std::left;
   using std::setw;

   typedef  std::list<std::string>    LS;
   typedef  LS::iterator              LSI;
   typedef  LS::const_iterator        LSCI;
   typedef  std::vector<std::string>  VS;
   typedef  VS::iterator              VSI;
   typedef  VS::const_iterator        VSCI;
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

   class ProcessCurDirFunctor
   {
      public:
         ProcessCurDirFunctor
            (
               Settings_t  const  &  Settings_,
               VS          const  &  Arguments_,
               VFR                &  FileVect_,
               LS                 &  Subdirs_
            )
            : Settings(Settings_), Arguments(Arguments_), FileVect(FileVect_), Subdirs(Subdirs_)
            {}
         void operator()(void); // defined below
      private:
         Settings_t  const  &  Settings;  // Const, so operator() can't alter this.
         VS          const  &  Arguments; // Const, so operator() can't alter this.
         VFR                &  FileVect;  // Non-const, so operator() can clear/write file vector.
         LS                 &  Subdirs;   // Non-const, so operator() can build list of subdirs for tree.
   };

   void Help (void);

} // end namespace ns_FDT


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  main()                                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

int main (int Beren, char * Luthien[])
{
   // Set main namespace we're using:
   using namespace ns_FDT;

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

   // Make a vector of file records (in "static" memory instead of the stack, else this can very easily
   // overflow the stack!!!):
   static VFR FileVect;

   // Reserve room for info on 10,000 files (this Allocates memory for 10,000 items, but it doesn't
   // actually bloat the vector to that size yet; it just creates contiguous block of 10,000 cells
   // of "reserved-but-unused" space, so that we don't have to keep re-allocating as the vector grows):
   FileVect.reserve(10000);

   // Make a list of strings to hold (name, path) pairs for subdirs:
   LS Subdirs;

   // Create a function object of type "ProcessCurDirFunctor" for use with CursDirs:
   ProcessCurDirFunctor ProcessCurDir (Settings, Arguments, FileVect, Subdirs);

   // Recursively decend directory tree, executing ProcessCurDir at each node:
   rhdir::CursDirs(ProcessCurDir);

   // We've finished building our list of subdirectories, so sort it and print it:
   Subdirs.sort();
   for ( LSCI i = Subdirs.begin() ; i != Subdirs.end() ; ++i )
   {
      cout << (*i) << endl;
   }

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
ns_FDT::
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

   BLAT("About to return from ProcessFlags.\n")
   return;
} // end ns_FDT::ProcessFlags()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessArguments()                                                      //
//                                                                          //
//  Sets program settings based on Arguments.                               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_FDT::
ProcessArguments
   (
      VS          const  &  Arguments,
      Settings_t         &  Settings
   )
{
   BLAT("\nJust entered ProcessArguments().\n")

   // Insert commands here to set settings based on arguments.

   BLAT("About to return from ProcessArguments.\n")
   return;
} // end ns_FDT::ProcessArguments()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurDirFunctor::operator()                                        //
//                                                                          //
//  Processes current directory.                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void ns_FDT::ProcessCurDirFunctor::operator() (void)
{
   BLAT("\nJust entered ProcessCurDirFunctor::operator().\n")

   // Get current directory:
   std::string CurDir = rhdir::GetFullCurrPath();

   // Get vector of FileRecords for all subdirs in current directory which match
   // the wildcards given by the command-line arguments, if any.
   // If no arguments were given, get all files:
   FileVect.clear();
   std::string Wildcard;
   if (Arguments.size() > 0)
   {
      for (VSCI i = Arguments.begin(); i != Arguments.end(); ++i)
      {
         Wildcard = *i;
         rhdir::LoadFileList
         (
            FileVect,  // Name of container to load.
            Wildcard,  // Dir-name wildcard.
            2,         // Dirs only (not files).
            2          // Append to vector without clearing.
         );
      }
   }
   else
   {
      rhdir::LoadFileList
      (
         FileVect,     // Name of container to load.
         "*",          // All subdirectories.
         2,            // Dirs only (not files).
         2             // No need to clear vector again, so just append.
      );
   }

   BLAT("\nIn ProcessCurDirFunctor::operator().")
   BLAT("Finished building file list.")
   BLAT("File list size is " << FileVect.size())
   BLAT("About to enter file-iteration for loop.\n")

   /* --------------------------------------------------------------- */
   /*  Iterate through the subdirs, recording child,parent for each:  */
   /* --------------------------------------------------------------- */
   for ( VFRI  i = FileVect.begin() ; i != FileVect.end() ; ++i )
   {
      std::ostringstream ChildParent;
      //ChildParent << setw(39) << left << i->name << left << i->dir;
      ChildParent << i->name << '\t' << i->dir;
      Subdirs.push_back(ChildParent.str());
   } // end for (each file in FileVect)

   BLAT("\nAt end of ProcessCurDirFunctor::operator(), about to return.\n")

   return;
} // end ns_FDT::ProcessCurDirFunctor::operator()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Help()                                                                  //
//                                                                          //
//  Prints help.                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_FDT::
Help
   (
      void
   )
{
   //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
   cout
                                                                                               << endl
   << "Welcome to Flatten Directory Tree, Robbie Hatley's nifty tool for"                      << endl
   << "displaying an alphabetical list of all subdirs of the current dir,"                     << endl
   << "showing full path for each subdir."                                                     << endl
                                                                                               << endl
   << "This version compiled at " << __TIME__ << " on " << __DATE__ << "."                     << endl
                                                                                               << endl
   << "Command-line syntax:"                                                                   << endl
   << "flatten-directory-tree [switches] [arguments] < InputFile > OutputFile"                 << endl
                                                                                               << endl
   << "Switch:                      Meaning:"                                                  << endl
   << "\"-h\" or \"--help\"             Print help and exit."                                  << endl
                                                                                               << endl
   << "The only switch is the help switch.  Any arguments will be interpretted as"             << endl
   << "wildcards, and only subdirectories matching those wildcards will be listed."            << endl
   << "There's not really much else to say, as this program is very simple."                   << endl
                                                                                               << endl;
   return;
} // end ns_FDT::Help()


/*

Development Notes:

At first I was thinking of doing this in some complicated recursion-based way, similar to
how I do "dedup-newsbin-multi", but then I realized that a more expediant way is to just
process each dir at a time, writing each subdir (name,path) pair to a string and appending
that string to a list of strings in main().  Then when we're finished traversing the tree,
just sort and print the list.  Voila.


*/


// end file template.cpp
