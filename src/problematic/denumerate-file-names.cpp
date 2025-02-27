#undef DEBUG_ENUMERATE
/************************************************************************************************************\
 * File name:       denumerate-file-names.cpp
 * Source for:      denumerate-file-names.exe
 * Program name:    Denumerate File Names
 * Author:          Robbie Hatley
 * Date written:    Sat Sep 3, 2005
 *
 * Notes:
 *    For each file in the current directory (and all its subdirectories, if an "-r" or "--recurse"
 *    switch is used), if the file name contains a "bracket expression" (a one- or two- digit number
 *    in brackets) or a "numerator" (a hyphen a hyphen followed by a 4-digit number in parentheses), this
 *    program will rename the file so as to remove the bracket-expression(s) and/or numerator(s) from the
 *    file name, provided that no file yet exists with the proposed simplified file name.
 *
 * Edit history:
 *    Sat Sep 03, 2005 - Wrote it.
 *    Fri Nov 09, 2007 - Fixed "runs after help" bug.
 *
 * To make, link with modules rhutil.o and rhdir.o in librh.a
\************************************************************************************************************/

#include <ctime>

#include <iostream>
#include <iomanip>
#include <list>
#include <string>
#include <sstream>

#include "rhutil.hpp"
#include "rhdir.hpp"



namespace ns_DFN
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
      uint32_t  DenCount;  // Count of file names successfully denumerated.
      void PrintStats (void)
      {
         cout
                                                                  << endl
            << "Finished denumerating file names in this tree."   << endl
            << "Directories processed:  " << setw(7) << DirCount  << endl
            << "Files examined:         " << setw(7) << FilCount  << endl
            << "Files bypassed:         " << setw(7) << BypCount  << endl
            << "Errors encountered:     " << setw(7) << ErrCount  << endl
            << "File names denumerated: " << setw(7) << DenCount  << endl
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
      Stats_t         &  Stats,
      FR       const  &  FileRec
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
   using namespace ns_DFN;
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
ns_DFN::
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
} // end ns_DFN::ProcessFlags()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurDirFunctor::operator()                                        //
//                                                                          //
//  Processes current directory.                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void ns_DFN::ProcessCurDirFunctor::operator() (void)
{
   // ABSTRACT:
   // This function adds numerators (such as "-(3956)") to the names of
   // all of the files in the current directory (and all its subdirectories,
   // if recursing).

   BLAT("\nJust entered ProcessCurDir::operator().\n")

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

   // Get vector of file records for all files in current directory which match
   // the wildcards given by the command-line arguments, if any.
   // If no arguments were given, get all files:
   std::string Wildcard;
   if (Arguments.size() > 0)
   {
      for (VS::const_iterator i = Arguments.begin(); i != Arguments.end(); ++i)
      {
         Wildcard = *i;
         rhdir::LoadFileList
         (
            FileList,  // Name of container to load.
            Wildcard,  // File-name wildcard.
            1,         // Files only (not dirs).
            1          // Clear list before adding files.
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

   // Process all files in list:
   for ( VFRCI i = FileList.begin() ; i != FileList.end() ; ++i )
   {
      ++Stats.FilCount;
      ProcessCurrentFile(Stats, *i);
   } // End for (each file in FileList)

   BLAT("\nAt bottom of ProcessCurDirFunctor::operator(); about to return.\n")
   return;
} // end ns_DFN::ProcessCurDirFunctor::operator()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurrentFile()                                                    //
//                                                                          //
//  Processes current file.                                                 //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_DFN::
ProcessCurrentFile
   (
      Stats_t         &  Stats,
      FR       const  &  FileRec
   )
{
   BLAT("\nJust entered ProcessCurrentFile();")
   BLAT("about to grab OldFileName.\n")

   // Grab old file name:
   std::string OldFileName = FileRec.name;

   BLAT("\nIn ProcessCurrentFile(); finished getting OldFileName;")
   BLAT("about to run Debracket().\n")

   // Debracket the file name:
   std::string DebracketedFileName = rhdir::Debracket(OldFileName);

   BLAT("\nIn ProcessCurrentFile(); finished debracketing old file name;")
   BLAT("about to denumerate the file name.\n")

   // Denumerate the file name:
   std::string NewFileName = rhdir::Denumerate(DebracketedFileName);

   BLAT("\nIn ProcessCurrentFile(); finished denumerating the file name;")
   BLAT("about to check if NewFileName == OldFileName.\n")

   // If the new file name is the same as the old, increment Stats.BypCount
   // and return silently:
   if (NewFileName == OldFileName)
   {
      ++Stats.BypCount;
      return;
   }

   BLAT("\nIn ProcessCurrentFile().")
   BLAT("Finished checking if NewFileName == OldFileName.")
   BLAT("(Obviously, they weren't the same, or we wouldn't be here.)")
   BLAT("Old name = " << OldFileName)
   BLAT("New name = " << NewFileName)
   BLAT("About to check to see if NewName exists.\n")

   // If file already exists with new name,
   // print warning and continue to next file:
   if (__file_exists(NewFileName.c_str()))
   {
      cerr
                                                                                  << endl
         << "Error in ns_DFN::DenumerateFileName() in denumerate-file-names.exe:" << endl
         << "Failed to denumerate file with name:"                                << endl
         << OldFileName                                                           << endl
         << "because a file already exists with name:"                            << endl
         << NewFileName                                                           << endl
         << "Moving on to next file."                                             << endl
                                                                                  << endl;
      ++Stats.ErrCount;
      return;
   }

   BLAT("\nIn ProcessCurrentFile().")
   BLAT("Finished making sure NewName does not exist.")
   BLAT("(Obviously, it didn't, or we wouldn't be here.)")
   BLAT("About to attempt file rename\n")

   std::cout << OldFileName << " -> " << NewFileName << std::endl;

   bool bSuccess = rhdir::RenameFile(OldFileName, NewFileName);
   if (bSuccess)
   {
      ++Stats.DenCount;
   }
   else
   {
      ++Stats.ErrCount;
      cerr
                                                                              << endl
         << "Error in ProcessCurrentFile() in denumerate-file-names.exe:"     << endl
         << "The following file rename failed:"                               << endl
         << "Old file name:  " << OldFileName                                 << endl
         << "New file name:  " << NewFileName                                 << endl
         << "Continuing with next file."                                      << endl
                                                                              << endl;

   }

   BLAT("\nAt end of ProcessCurrentFile(); about to return.\n")
   return;
} // end ns_DFN::ProcessCurrentFile()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Help()                                                                  //
//                                                                          //
//  Prints help.                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_DFN::
Help
   (
      void
   )
{
   cout
      << "Welcome to Robbie Hatley's file name denumerating program,"                          << endl
      << "denumerate-file-names.exe ."                                                         << endl
                                                                                               << endl
      << "This version compiled at " << __TIME__ << "on " << __DATE__ << " ."                  << endl
                                                                                               << endl
      << "This program removes any instances of \"bracket expressions\" (\"[#]\" or \"[##]\")" << endl
      << "or \"numerators\" (\"-(####)\") from the names of all files in the current"          << endl
      << "directory (and all its subdirectories if an \"-r\" or \"--recurse\" switch is"       << endl
      << "used), provided that no files yet exist with the simplified file names."             << endl
                                                                                               << endl
      << "This program is especially useful for cleaning up the names of files downloaded"     << endl
      << "from Usenet through NewsBin, or copied from the Temporary Internet Files folder."    << endl;
   return;
} // end ns_DFN::Help()

// end file denumerate-file-names.cpp
