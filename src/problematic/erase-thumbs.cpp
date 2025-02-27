
/************************************************************************************************************\
   File name:      remove-thumbs.cpp
   Source for:     remove-thumbs.exe
   Program Name:   Remove Thumbs
   Author:         Robbie Hatley
   Date written:   Sat May 31, 2008
   Inputs:         An optional command line argument, which must be one of these switches:
                   "-r" or "--recurse" to recurse subdirectories
                   "-h" or "--help" for help

   Definitions:

      "numerator":
         A substring in a file name of the form "-(####)", where "#" stands for any digit.

      "pathological file name":
         A file name which, if all numerators are removed, has an empty prefix.

      "name root":
         The file name that is obtained by erasing all instances of "-(####)" substrings (where "#" stands
         for any digit) from the prefix of a file name, then converting all letters (if any) in the name
         to lower case.  If the prefix of the name root is empty, the orignal file name was pathological.
         Examples:
            File Name:                Name Root:
            sAm.TxT                   sam.txt          (Just converted to all-lower-case)
            sam-(3764).txt            sam.txt          (Erased "-(3764)" substring.)
            SAM-(3764)-(3967).TXT     sam.txt          (Erased all "-(####)" substrings.)
            sam-(28578).txt           sam-(28578).txt  (No "-(####)" substring.)
            -(8823)                                    (Empty string.  Original name was pathological.)
            a-(8823)                  a                (Erased "-(8823)" substring.)
            -(6441)-(3665).txt        .txt             (Empty prefix.  Original name was pathological.)

      "name group":
         A group of non-pathological files with the same name root.

   Actions:
      For each pair of files with non-pathological names, if the two files have the same name root but
      different numerators and sizes which differ by 10% or more, this program will erase the smaller
      of the two files.  This is great for getting rid of "thumbnail" pictures, hence the name of this
      program.

   WARNING:
      DO NOT USE THIS PROGRAM UNLESS YOU ARE SURE THAT ANY PAIR OF FILES IN THE CURRENT DIRECTORY
      WHICH HAVE THE SAME NAME ROOT ARE PICTURES WHICH ARE IDENTICAL EXCEPT FOR SIZE AND RESOLUTION.

   Methodology (how this program goes about accomplishing the above actions):
      1. The names of all files in the current directory  with non-pathological names are loaded into a
         multimap M, keyed by name root.  Each pathological file is noted and bypassed, and an alert is
         given.
      2. The program iterates through all name groups.  Name groups with more or less than 2 files are
         skipped.  Name groups where the smaller file is less than 10% smaller than the larger file
         are skipped.  For the remaining groups, the smaller file is erased from the disk.

   Dependencies:
      rhutil.h, rhdir.h, librh.a, unistd.h (djgpp compiler-dependent header; see www.delorie.com).
   To make:
      Compile with djgpp (see www.delorie.com) and link with rhutil.o and rhdir.o in library librh.a .
   Edit history:
      Sat May 31, 2008 - Wrote it.
\************************************************************************************************************/

// Use asserts?
#undef NDEBUG
//#define NDEBUG
#include <assert.h>

#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>
#include <list>
#include <string>
#include <map>

#include <cstdlib>
#include <cstring>
#include <cctype>

// define or undef BLAT_ENABLE here to enable/disable debug output macro
// "BLAT", located in rhutil.h (obviously, this line must come BEFORE
// the line that includes rhutil.h):

//#define BLAT_ENABLE

#include "rhutil.hpp"

#include "rhdir.hpp"

namespace ns_EraseThumbs
{
   // "using" declarations:
   using std::cout;
   using std::cerr;
   using std::endl;

   // Make some useful typedefs:
   typedef rhdir::FileRecord               FR;    // File Record
   typedef std::multimap<std::string, FR>  FRM;   // File Record Multimap
   typedef FRM::iterator                   FRMI;  // File Record Multimap Iterator
   typedef FRM::const_iterator             FRMCI; // File Record Multimap Constant Iterator
   typedef std::list<std::string>          LS;    // List of Strings
   typedef LS::iterator                    LSI;   // List of Strings Iterator
   typedef LS::const_iterator              LSCI;  // List of Strings Constant Iterator
   typedef std::vector<std::string>        VS;    // Vector of Strings
   typedef VS::iterator                    VSI;   // Vector of Strings Iterator
   typedef VS::const_iterator              VSCI;  // Vector of Strings Constant Iterator


   // Types:

   struct Flags_t // program flags
   {
      bool bBeast;  // Special selection mode for deciding which files to delete.
      bool bCurse;  // Recursively traverse directory tree, downward from current node (no cross-compare).
      bool bMulti;  // Span multiple hard drives (no cross-compare).
      bool bDrivD;  // Include drive D in multi-drive recursion.
      bool bDrivE;  // Include drive E in multi-drive recursion.
      bool bDrivF;  // Include drive F in multi-drive recursion.
      bool bDrivG;  // Include drive G in multi-drive recursion.
      bool bDrivH;  // Include drive I in multi-drive recursion.
      bool bDrivI;  // Include drive J in multi-drive recursion.
      bool bDrivJ;  // Include drive K in multi-drive recursion.
   };

   struct Stats_t // program statistics
   {
      uint32_t  DirCount;
      uint32_t  GroupCount;
      uint32_t  FileCount;
      uint32_t  DelCount;
   };

   class ProcessCurDirFunctor
   {
      public:
         ProcessCurDirFunctor(FRM & M, LS & Keys) : M_(M), Keys_(Keys) {}
         void operator()(void); // defined below
      private:
         FRM  &  M_;
         LS   &  Keys_;
   };


   // Function Prototypes:

   inline
   bool
   InArgs
      (
         VS           const  &  Arguments,
         std::string  const  &  Text
      );

   void
   ProcessArguments
      (
         VS           const  &  Arguments,
         Flags_t             &  Flags
      );

   void
   EraseThumbs
      (
         Flags_t      const  &  Flags,
         Stats_t             &  Stats
      );

   int
   EradicateDuplicates
      (
         FRM                 &  M,             // The Multimap.
         std::string  const  &  Key,           // Key of current file group.
         Flags_t      const  &  Flags,         // Program flags.
         Stats_t             &  Stats          // Program statistics.
      );

   void
   LoadFileNameMap
      (
         FRM                 &  M,
         LS                  &  Keys,
         Flags_t      const  &  Flags,
         Stats_t             &  Stats
      );

   bool
   IsPathological
      (
         std::string  const  &  Name
      );

   bool
   IsCandidate
      (
         std::string  const  &  Name
      );

   void
   PrintStats
      (
         Stats_t      const  &  Stats
      );

   void
   Help
      (
         void
      );

} // End namespace rhdedup


// ==================== FUNCTION DEFINITIONS: ================================================================

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  main()                                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

int main(int Beren, char *Luthien[])
{
   using namespace ns_EraseThumbs;

   BLAT("In main().  At top of function.  About to run HelpDecider.");

   // If command line contains "--help" or "-h" give instructions then return:
   if (rhutil::HelpDecider(Beren, Luthien, Help)) {return 777;}

   BLAT("In main().  Finished with help decider; about to get arguments.");

   // Get arguments:
   VS Arguments;
   rhutil::GetArguments(Beren, Luthien, Arguments);

   BLAT("In main().  Finished getting arguments; about to process arguments.");

   // Set program flags based on arguments:
   Flags_t Flags = Flags_t();
   ProcessArguments(Arguments, Flags);

   BLAT("Finished getting system-state flags; about to run EraseThumbs().");

   // Run EraseThumbs() and collect program statistics:
   Stats_t Stats = Stats_t();
   EraseThumbs(Flags, Stats);

   BLAT("Finished with EraseThumbs().  About to run PrintStats().");

   // Print statistics (counts of directories processed, files processed,
   // files renamed, and files erased):
   PrintStats(Stats);

   BLAT("Finished with PrintStats().  About to return from application.");

   // If we get to here without having crashed and burned, return 0:
   return 0;

} // End main()


/////////////////////////////////////////////////////////////////////////////////////
//                                                                                 //
//  InArgs()                                                                       //
//                                                                                 //
//  Determine whether a given string is in Arguments.                              //
//                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////

inline
bool
ns_EraseThumbs::
InArgs
   (
      VS           const  &  Arguments,
      std::string  const  &  Text
   )
{
   return Arguments.end() != find(Arguments.begin(), Arguments.end(), "J");
}


/////////////////////////////////////////////////////////////////////////////////////
//                                                                                 //
//  Process Arguments()                                                            //
//                                                                                 //
//  Sets program-state flags based on arguments.                                   //
//                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////

void
ns_EraseThumbs::
ProcessArguments
   (
      VS       const  &  Arguments,
      Flags_t         &  Flags
   )
{
   Flags.bCurse = InArgs(Arguments, "-r") || InArgs(Arguments, "--recurse");
   Flags.bBeast = InArgs(Arguments, "-b") || InArgs(Arguments, "--beast"  );
   if (InArgs(Arguments, "D")) {Flags.bMulti = true; Flags.bDrivD = true;}
   if (InArgs(Arguments, "E")) {Flags.bMulti = true; Flags.bDrivE = true;}
   if (InArgs(Arguments, "F")) {Flags.bMulti = true; Flags.bDrivF = true;}
   if (InArgs(Arguments, "G")) {Flags.bMulti = true; Flags.bDrivG = true;}
   if (InArgs(Arguments, "H")) {Flags.bMulti = true; Flags.bDrivH = true;}
   if (InArgs(Arguments, "I")) {Flags.bMulti = true; Flags.bDrivI = true;}
   if (InArgs(Arguments, "J")) {Flags.bMulti = true; Flags.bDrivJ = true;}
   return;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//  EraseThumbs()                                                                                           //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void
ns_EraseThumbs::
EraseThumbs
      (
         Flags_t  const  &  Flags,
         Stats_t         &  Stats
      )
{
   BLAT("Just entered ns_EraseThumbs::DedupNewsbinFiles().");

   // Make a multimap of file records in this tree, keyed by root file name:
   std::multimap<std::string, rhdir::FileRecord> M;

   // Make a list of root file names:
   std::list<std::string> Keys;

   // Load file records for all files in this directory into M,
   // and load all candidate root file names into L:

   BLAT("About to execute LoadFileNameMap(M, Keys, Flags, Stats); ...");

   LoadFileNameMap(M, Keys, Flags, Stats);

   BLAT("finished executing LoadFileNameMap(M, Keys, Flags, Stats);")

   // If M.size() is less than 2, this tree cannot contain duplicates, so return:
   if (M.size() < 2) {return;}

   // If we get to here, this directory has at least 2 files in it, so iterate through our list of
   // root file names, and examine ONLY those name groups in M which are keyed by names in Keys.
   // (This should save ENORMOUS amounts of time compared to how I WAS doing it!)

   // For each name key in Keys:
   for (LSI i = Keys.begin(); i != Keys.end(); ++i)
   {
      // Assert that a group in M with key (*i) actually does exist:
      assert(M.lower_bound(*i) != M.end());

      // Assert that this group is not empty:
      assert(M.upper_bound(*i) != M.lower_bound(*i));

      // Announce the name root for this file group:
      ++Stats.GroupCount;
      BLAT("Name group #" << Stats.GroupCount << ", files with name root \"" << (*i) << "\":")

      // For each file in this name group, increment global counter FileCount:
      for (FRMI Current = M.lower_bound(*i); Current != M.upper_bound(*i); ++Current)
      {
         ++Stats.FileCount;
         BLAT("   " << Current->second.name)
      }

      // Search for pairs of duplicate files in this group; for each such pair found, erase the newer:
      BLAT("In ns_EraseThumbs::EraseThumbs(), "
         "about to call ns_EraseThumbs::EradicateDuplicates().")
      EradicateDuplicates(M, *i, Flags, Stats);
      BLAT("In ns_EraseThumbs::EraseThumbs(), "
         "just returned from ns_EraseThumbs::EradicateDuplicates().")

   } // end for (each key in L)

   BLAT("About to return from ns_EraseThumbs::EraseThumbs().")
   return;

} // end function void ns_EraseThumbs::EraseThumbs()


/////////////////////////////////////////////////////////////////////////////////////
//                                                                                 //
//  EradicateDuplicates()                                                          //
//                                                                                 //
//  Erases all duplicate files in current file name group.                         //
//                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////

int
ns_EraseThumbs::
EradicateDuplicates
      (
         FRM                &  M,             // The Multimap.
         std::string const  &  Key,           // Key of current file group.
         Flags_t     const  &  Flags,         // Program flags.
         Stats_t            &  Stats          // Program statistics.
      )
{
   BLAT("Just entered ns_EraseThumbs::EradicateDuplicates().")

   // Define the iterators we'll need:
   FRMI LowerBound, UpperBound, Current, Compare;

   // Make a flag to indicate whether we erased any files during the last comparison loop (ie, the inner
   // "for" loop below):
   bool bErasedFile;

   // Loop at least once, then continue to loop while bErasedFile is true:
   do
   {
      // Reset erase flag to false, since we haven't erased any files yet this loop:
      bErasedFile = false;

      // Get iterators to beginning and end of this name group (WE MUST GET FRESH ITERATORS EVERY
      // TIME THROUGH THE LOOP!!!  OTHERWISE THEY BECOME INVALID ON ERASURE OF MULTIMAP ELEMENTS):
      LowerBound = M.lower_bound(Key); // iterator to first         item in this file group
      UpperBound = M.upper_bound(Key); // iterator to one-past-last item in this file group

      // Assert that LowerBound is not equal to the end marker for M (ie, this name group actually does exist):
      assert(LowerBound != M.end());

      // Assert that UpperBound is not equal to LowerBound (ie, this name group is not empty):
      assert(UpperBound != LowerBound);

      // For each file in the group:
      for (Current = LowerBound; Current != UpperBound; ++Current)
      {

         BLAT(endl << "Processing Current file " << Current->second.path())

         // See if current file is a duplicate of any file to its right.  If so, delete the newer file,
         // delete its entry in M, set bErasedFile to true, and break out of both inner and outer "for" loops:
         for (Compare = Current, ++Compare; Compare != UpperBound; ++Compare)
         {
            // Assert that Compare->second.path() is not NCS_Equal to Current->second.path()
            // (ie, we're not about to compare a file to itself!!!):
            assert(!rhutil::NCS_Equal(Compare->second.path(), Current->second.path()));

            // Assert that the "Current" and "Compare" files actually do exist:
            assert(rhdir::FileExists(Current->second.path()));
            assert(rhdir::FileExists(Compare->second.path()));

            // If sizes don't match, continue to next "Compare" file:
            bool bSizeMatch = (Current->second.size == Compare->second.size);
            BLAT("bSizeMatch = " << std::boolalpha << bSizeMatch)
            if (!bSizeMatch)
            {
               BLAT("In ns_EraseThumbs::EradicateDuplicates(), skipping to next file because "
                  "bSizeMatch is false.")
               continue;
            }

            // If files aren't identical, continue to next "Compare" file:
            bool bIdentical = rhdir::FilesAreIdentical(Current->second.path(), Compare->second.path());
            BLAT("bIdentical = " << std::boolalpha << bIdentical);
            if (!bIdentical)
            {
               BLAT("In ns_EraseThumbs::EradicateDuplicates(), skipping to next file because "
                  "bIdentical is false.")
               continue;
            }

            // If we get to here, Current and Compare files are the same size and compare identical.

            // We're about to delete a file, so increment deletion counter:
            ++Stats.DelCount;

            // Find out Which file is newer, store the names of the newer and older files in
            // variables called "NewerFile" and "OlderFile", and erase the newer file from
            // the MultiMap:
            rhdir::FileRecord NewerFile, OlderFile;

            if (Current->second.timestamp > Compare->second.timestamp)
            {
               NewerFile = Current->second;
               OlderFile = Compare->second;
               M.erase(Current);
            }
            else
            {
               NewerFile = Compare->second;
               OlderFile = Current->second;
               M.erase(Compare);
            }
//AARDVARK

            // ECHIDNA: Must come up with a better algorithm for deciding which files to
            // erase!  Always prefer erasing presort and incoming over erasing files in
            // other folders!


            // If (Flags.bBeast and (older file name contains "-(6666)") ), erase older file:
            if (Flags.bBeast and std::string::npos != OlderFile.name.find("-(6666)"))
            {
               // Announce deletion of older file:
               cout
                  << endl
                  << "Duplicate deletion #" << Stats.DelCount << ":" << endl
                  << OlderFile.path() << endl
                  << " is a duplicate of " << endl
                  << NewerFile.path() << endl
                  << "Deleting " << OlderFile.path() << endl;

               // Erase file:
               remove(OlderFile.path().c_str());
            }

            // Otherwise, delete the newer of the two files:
            else
            {
               // Announce deletion of newer file:
               cout
                  << endl
                  << "Duplicate deletion #" << Stats.DelCount << ":" << endl
                  << NewerFile.path() << endl
                  << " is a duplicate of " << endl
                  << OlderFile.path() << endl
                  << "Deleting " << NewerFile.path() << endl;

               // Erase file:
               remove(NewerFile.path().c_str());
            }

            // Set flag to indicate we've erased a file:
            bErasedFile = true;

            // Break from this inner "for" loop:
            break;

         } // end for (each Compare file)

         // If we erased a file in the inner "for" loop, break from outer "for" loop as well:
         if (bErasedFile) break;

      } // end for (each Current file)

   } while (bErasedFile);

   BLAT("About to return from ns_EraseThumbs::EradicateDuplicates().")
   return 0;

} // end EradicateDuplicates()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  LoadFileNameMap()                                                       //
//                                                                          //
//  Loads all file names in current tree into a std::multimap of            //
//  rhdir::FileRecord's keyed by "root file name" (the file name minus any  //
//  "-(3867)" additions from NewsBin).  Also keeps track of all "candidate" //
//  root file names in a separate list.                                     //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_EraseThumbs::
LoadFileNameMap
   (
      FRM             &  M,
      LS              &  Keys,
      Flags_t  const  &  Flags,
      Stats_t         &  Stats
   )
{
   // Clear M and Keys:
   M.clear();
   Keys.clear();

   // If doing cross-drive recursion, collect all file info from all listed drives:
   if (Flags.bMulti)
   {
      if (Flags.bDrivD)
      {
         system ("D");
         system ("CD \\");
         Stats.DirCount += rhdir::CursDirs(ProcessCurDirFunctor(M, Keys));
      }
      if (Flags.bDrivE)
      {
         system ("E");
         system ("CD \\");
         Stats.DirCount += rhdir::CursDirs(ProcessCurDirFunctor(M, Keys));
      }
      if (Flags.bDrivF)
      {
         system ("F");
         system ("CD \\");
         Stats.DirCount += rhdir::CursDirs(ProcessCurDirFunctor(M, Keys));
      }
      if (Flags.bDrivG)
      {
         system ("G");
         system ("CD \\");
         Stats.DirCount += rhdir::CursDirs(ProcessCurDirFunctor(M, Keys));
      }
      if (Flags.bDrivH)
      {
         system ("H");
         system ("CD \\");
         Stats.DirCount += rhdir::CursDirs(ProcessCurDirFunctor(M, Keys));
      }
      if (Flags.bDrivI)
      {
         system ("I");
         system ("CD \\");
         Stats.DirCount += rhdir::CursDirs(ProcessCurDirFunctor(M, Keys));
      }
      if (Flags.bDrivJ)
      {
         system ("J");
         system ("CD \\");
         Stats.DirCount += rhdir::CursDirs(ProcessCurDirFunctor(M, Keys));
      }
   }

   // Else if branch-recursing, recursively descend tree from current node:
   else if (Flags.bCurse)
   {
      Stats.DirCount = rhdir::CursDirs(ProcessCurDirFunctor(M, Keys));
   }

   // Otherwise, process current directory only:
   else
   {
      ProcessCurDirFunctor(M, Keys)();
      Stats.DirCount = 1;
   }

   return;
}


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurDirFunctor::operator()()                                      //
//                                                                          //
//  Loads all file names in current directory into a std::multimap of       //
//  rhdir::FileRecord's keyed by "root file name" (the file name minus any  //
//  "-(3867)" additions from NewsBin).  Also keeps track of all "candidate" //
//  root file names in a separate list.                                     //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_EraseThumbs::
ProcessCurDirFunctor::
operator()
   (
      void
   )
{
   ffblk              File_Block    = ffblk();
   rhdir::FileRecord  File_Record   = rhdir::FileRecord();
   std::string        File_Name     = std::string();
   std::string        Name_Root     = std::string();
   int                done          = 0;

   BLAT("Just entered ns_EraseThumbs::ProcessCurDirFunctor::operator().")

   // To prevent problems with file renames, deletions, and comparisons, change all tildes in file names
   // in current directory into underscores:
   rhdir::UnTilde();

   // Get curr. dir.:
   std::string CurrDir ( rhdir::GetFullCurrPath() );

   // Set "File_Flags" variable to accept all files and directories except volume lables:
   uint8_t File_Flags ( FA_RDONLY | FA_HIDDEN | FA_SYSTEM | FA_ARCH );

   // Search for all files, but not directories or volume labels, in current directory:
   for (done = findfirst("*", &File_Block, File_Flags) ; not done ; done = findnext(&File_Block))
   {
      // Get file record from file block:
      File_Record = rhdir::FileRecord(File_Block, CurrDir);

      // Get file name from file record:
      File_Name = File_Record.name;

      BLAT("Retrieved a file name from the directory: " << File_Name)

      // If this file name is pathological, print warning and skip to next file:
      BLAT("In ns_EraseThumbs::ProcessCurDirFunctor::operator();")
      BLAT("about to call ns_EraseThumbs::IsPathological().")
      bool bPath = ns_EraseThumbs::IsPathological(File_Name);
      BLAT("In ns_EraseThumbs::ProcessCurDirFunctor::operator();")
      BLAT("just returned from ns_EraseThumbs::IsPathological().")
      if (bPath)
      {
         cerr
            << "Warning: file name " << File_Name << " is pathological." << endl
            << "Skipping to next file." << endl;
         continue;
      }

      // Get the name root for this file name by stripping-out all instances of "-(####)" substrings
      // from current file name and converting result to all-lower-case to prevent duplicates:

      BLAT("In ns_EraseThumbs::ProcessCurDirFunctor::operator(), about to call rhdir::Denumerate().")
      Name_Root = rhutil::StringToLower(rhdir::Denumerate(File_Name));
      BLAT("In ns_EraseThumbs::ProcessCurDirFunctor::operator(), just returned from rhdir::Denumerate().")
      BLAT("Name Root:   " << Name_Root)
      BLAT("File Record: " << File_Record)

      // Insert the current file name into M, keyed by name root:
      M_.insert(std::make_pair(Name_Root, File_Record));

      // If current file name is a candidate, push it's name root onto our stack of name roots for which
      // associated candidate files exist:
      if (ns_EraseThumbs::IsCandidate(File_Name))
      {
         Keys_.push_back(Name_Root);
      }
   }

   // Now that all of the files in the current directory have been processed, sort and dedup Keys:
   rhutil::SortDup(Keys_);

   // Return to calling function:
   BLAT("About to return from ProcessCurDirFunctor::operator().")
   return;
} // end void ns_EraseThumbs::ProcessCurDirFunctor::operator()(void)


//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//  IsPathological()                                                                    //
//  Decides whether or not a file name is "pathological"; that is, whether the prefix   //
//  and/or suffix would be empty if all numerators are removed.                         //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

bool
ns_EraseThumbs::
IsPathological
      (
         std::string const & Name
      )
{
   BLAT("Just entered ns_EraseThumbs::IsPathological().")

   BLAT("In ns_EraseThumbs::IsPathological(), about to call rhdir::Denumerate().")
   std::string StrippedName = rhdir::Denumerate(Name);
   BLAT("In ns_EraseThumbs::IsPathological(), just returned from rhdir::Denumerate().")

   std::string Prefix = rhdir::GetPrefix(StrippedName);
   std::string Suffix = rhdir::GetSuffix(StrippedName);
   if (Prefix.empty() || Suffix.empty())
   {
      BLAT("About to return true from ns_EraseThumbs::IsPathological().")
      return true;
   }
   else
   {
      BLAT("About to return false from ns_EraseThumbs::IsPathological().")
      return false;
   }
}



//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  IsCandidate()                                                           //
//  Decides whether or not a file name is a "candidate" for possibly being  //
//  a duplicate NewsBin file.  Returns true if-and-only-if the argument     //
//  string is at least 8 characters long and contains at least one          //
//  "-(####)" substring, where "#" means "any digit".                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

bool
ns_EraseThumbs::
IsCandidate
      (
         std::string const & Name
      )
{
   BLAT("Just entered ns_EraseThumbs::IsCandidate().")

   // If name is pathological, file is not a candidate:
   BLAT("In ns_EraseThumbs::IsCandidate(), about to call ns_EraseThumbs::IsPathological().")
   bool bPatho = ns_EraseThumbs::IsPathological(Name);
   BLAT("In ns_EraseThumbs::IsCandidate(), just returned from ns_EraseThumbs::IsPathological().")
   if (bPatho)
   {
      BLAT("About to return false from ns_EraseThumbs::IsCandidate() because file name is pathological.")
      return false;
   }

   // If non-pathological name has a numerator, it's a candidate:
   // NOTE: Can't subtract anything from Name.length(), because it's unsigned!!!  1 - 7 = 4294967290 !!!
   //for (std::string::size_type Index = 0; Index <= Name.length() - 7; ++Index) // NOOOOOOOOOOO!!!!!!!!
   for   (std::string::size_type Index = 0; Index + 6 < Name.length() ; ++Index) // YEEEEESSSSSS!!!!!!!!
   {
      if
      (
            '-' ==  Name[Index + 0]
         && '(' ==  Name[Index + 1]
         && isdigit(Name[Index + 2])
         && isdigit(Name[Index + 3])
         && isdigit(Name[Index + 4])
         && isdigit(Name[Index + 5])
         && ')' ==  Name[Index + 6]
      )
      {
         BLAT("About to return true from ns_EraseThumbs::IsCandidate().")
         return true;
      }
   }

   BLAT("About to return false from ns_EraseThumbs::IsCandidate().")
   return false;
}


///////////////////////////////////////////////////////
//                                                   //
//  PrintStats()                                     //
//  Print statistics.                                //
//                                                   //
///////////////////////////////////////////////////////

void
ns_EraseThumbs::
PrintStats
      (
         Stats_t  const  &  Stats
      )
{
   cout
      << endl
      << endl
      << "Directories processed:    " << Stats.DirCount   << endl
      << "Name groups examined:     " << Stats.GroupCount << endl
      << "Files examined:           " << Stats.FileCount  << endl
      << "Duplicate files deleted:  " << Stats.DelCount   << endl;
   return;
}


///////////////////////////////////////////////////////
//                                                   //
//  Help()                                           //
//  Print help                                       //
//                                                   //
///////////////////////////////////////////////////////

void
ns_EraseThumbs::
Help
      (
         void
      )
{
   cout
   << "Welcome to dedup-newsbin-files.exe, Robbie Hatley's duplicate newsbin file"       << endl
   << "remover."                                                                         << endl
                                                                                         << endl
   << "This version was compiled at " << __TIME__ << " on " << __DATE__ << "."           << endl
                                                                                         << endl
   << "dedup-newsbin-files.exe erases duplicate files in the current directory which"    << endl
   << "have been downloaded from Usenet with NewsBin and have names of the form"         << endl
   << "\"niftyfile-(0012).xyz\".  Two files are considered duplicates (and the newer"    << endl
   << "of them is erased) if and only if they share the same name root, have exactly"    << endl
   << "the same length in bytes, and compare identical byte-by-byte.  For each pair"     << endl
   << "of identical files with the same name root, the newer of the two is erased."      << endl
                                                                                         << endl
   << "If an -r or --recurse switch is used, all of the subdirectories of the current"   << endl
   << "directory will also be processed."                                                << endl
                                                                                         << endl
   << "If one or more drive letters are used as arguments, all directories in all"       << endl
   << "given drives will be processed.  (This over-rides -r or --recurse.)"              << endl
   << "The drive letters must be upper-case, and separated by spaces."                   << endl
                                                                                         << endl
   << "With recursive or cross-drive processing, the files in different directories"     << endl
   << "are compared against each other, so this is a good way to search for files on"    << endl
   << "one drive which are duplicates of files on another drive."                        << endl
                                                                                         << endl
   << "If an -h or --help switch is used, the application will just print these"         << endl
   << "instructions and exit.  (This over-rides all other flags.)"                       << endl;
   return;
}
