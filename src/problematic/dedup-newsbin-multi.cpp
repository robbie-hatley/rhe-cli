/*
   Program Name:         DeDup Newsbin Multi
   File name:            dedup-newsbin-multi.cpp
   Source for:           dedup-newsbin-multi.exe
   Author:               Robbie Hatley
   Date written:         Late 2008 (but based on "DeDup Newsbin Files", written Thu Jan 02, 2003).
   Description:          Erases duplicate "SplatBlat-(3867).xyz" type NewsBin files
   Arguments:            Zero or one command-line arguments.  An argument must be one of:
                         "-r" or "--recurse"  for recursion
                         "-h" or "--help"     for instructions

   Note:                 If a "-r" or "--recurse" switch is used, this program processes file sets both in
                         the current directory and in each of its subdirectories, infinite levels deep.
                         (Files in one directory are never compared to files in another directory for
                         duplicateness, however; only files within each directory are compared.  For a time,
                         I tried cross-directory comparison, but the result was that this program then
                         proceeded to partially-dismantle file sets in one directory because some of the
                         files happened to exist in another directory.  No, better to leave "distant"
                         duplicates alone.  For one thing, they serve as backups in case of file damage.)

                         If a "-r" or "--recurse" switch is NOT used, only the current directory is processed.

   Definitions:

      "prefix":
         That portion of a file name to the left of the right-most dot, or the entire file name if there is
         no dot.

      "suffix":
         That portion of a file name to the right of the right-most dot, or an empty string if there is
         no dot.

      "numerator":
         A substring in a file name of the form "-(####)", where "#" stands for any digit.

      "pathological file name":
         A file name which, if all numerators are removed, has an empty prefix and/or an empty suffix.

      "candidate":
         A non-pathological file name which contains one or more numerators.

      "name root":
         The file name that is obtained by erasing all instances of "-(####)" substrings (where "#" stands for
         any digit) from the prefix of a file name, then converting all letters (if any) in the name to
         lower case.  If the prefix of the name root is empty, the orignal file name was pathological.
         Examples:
            File Name:                Name Root:
            sAm.TxT                   sam.txt          (Just converted to all-lower-case)
            sam-(3764).txt            sam.txt          (Erased "-(3764)" substring.)
            SAM-(3764)-(3967).TXT     sam.txt          (Erased all "-(####)" substrings.)
            sam-(28578).txt           sam-(28578).txt  (No "-(####)" substring.)
            -(8823)                                    (Empty prefix.  Original name was pathological.)
            a-(8823)                  a                (Erased "-(8823)" substring.)
            -(6441)-(3665).txt        .txt             (Empty prefix.  Original name was pathological.)

      "name group":
         A group of non-pathological files with the same name root.

      "NCS_Equal":
         Two strings are "NCS_Equal" if they are non-case-sensitively equal.  Eg, "RaT" and "rAt" are
         NCS_Equal.

      "master file":
         A file in a file group whose name is NCS_Equal to the group's name root.


   Pragmatology (what this program does):
      1. Sort all files in the current directory into name groups.  For each pathological file name
         encountered, print an alert and bypass that file.
      2. For only those name groups which contain candidate files:
         a. For each pair of duplicate files in the group, erase the newer file, even if that file is a
            master file for the name group.
         b. Do NOT rename any files.  (Change as of Sat Sep 03, 2005.  Now use program "denumerate-file-names"
            if numerator-removal is desired.)

   Methodology (how this program goes about accomplishing the above actions):
      1. The names of all files in the current directory  with non-pathological names are loaded into a
         multimap M, keyed by name root.  Each pathological file is noted and bypassed, and an alert is given.
         Each candidate file is noted, and the corresponding name root is pushed onto a list called "Keys".
      2. The program looks at just those name groups in M whose keys are entires in "Keys".  All other
         name groups in M are ignored.  (Basically, this means that name groups with 2 or more entries are
         paid-attention-to, while name groups with only 1 entry are ignored.)  For each key in "Keys",
         iterate through the entries in the name group with that key, comparing each file to all of the files
         to its right in its name group.  For each pair of duplicate files found, erase the newer file, even
         if it is a master file for the name group.  After each erasure, start the file comparisons over
         again from the beginning, until we are able to compare all files in the group and find no duplicates.
         Impliment this as an inner "for" loop (for each "compare" file), inside an outer "for" loop
         (for each "current" file), inside a "do-while" loop which tests for an erasure flag.

   Dependencies:
      rhutil.h, rhdir.h, librh.a, unistd.h (djgpp compiler-dependent header; see www.delorie.com).


   To make:
      Compile with djgpp (see www.delorie.com) and link with rhutil.o and rhdir.o in library librh.a .


   Edit history:
      Thu Jan 02, 2003 - Starting development on this program.
      Sat Jun 26, 2004 - Made some corrections.
      Mon Dec 20, 2004 - Debugged bizarre lockup in Demote()... turns out both Demote() and Dedup() were
                         hopelessly inefficient for large directories (over about 4000 entries).
                         I completely re-engineered the entire paradigm of this program so that it
                         no longer even looks at files that are not related to candidates by the same
                         root file name.  It now uses a multimap in conjunction with a key list to
                         drastically reduce run time for large directories.
      Wed Dec 22, 2004 - Changed file renaming method from _rename() to RenameFile(), and added "try" and
                         "catch" blocks.
      Sat Jan 08, 2005 - I heavily edited the above comments, and restructured the methodology to fix some
                         errors that were occurring (eg: the program was trying to erase files corresponding
                         to non-existant dummy entries in the multimap; also, it was erasing nearly every
                         file in a group whether it was a duplicate of anything or not.)
      Sun Jan 09, 2005 - Fixed program so that it doesn't freak-out if it sees more than one "-(####)"
                         construct in a file name.  (The name root becomes the name minus the right-most
                         instance of a "-(####)" construct in the name.)
      Sun Jan 16, 2005 - Added assert() calls to simplify error checking.
      Mon Jan 17, 2005 - Broke "DedupNewsbinFiles()" into multiple functions for improved readability,
                         understandability, testibility, and reliability.  Also improved comments.
      Wed Mar 30, 2005 - Altered SimplifyFileName() to erase right-most instances of "-(####)" substrings
                         from file names while they contain at least one such substring and remain at least
                         8 characters long.  This was necessary to fix a persistant bug that sometimes
                         crashes the program when multiple "-(####)" substrings are present in file names.
                         Also added and heavily re-wrote many comments.
      Tue Aug 09, 2005 - Added definitions of "prefix" and "pathological file name".  Changed actions to first
                         re-name files with pathological names to "aaaaaaaa.ext" where "a" stands for "any
                         letter" and "ext" stands for "any (or no) extention".
      Sun Sep 04, 2005 - Renamed program to "dedup-newsbin-files" to more-accurately describe what it does.
                         Also dramatically simplified it's operations.  This program now makes no attempt
                         to rename any files.  It merely erases duplicate files with the same name root.
                         For each pair of duplicate files, the newest is erased, even if it's a master file.
      Wed Dec 28, 2005 - Got rid of function SizeMatch().  Also added support for command-line switch -b or
                         --beast, which will cause the program to erase the older file instead of the newer if
                         the name of the older file contains "-(6666)".
      ??? Oct ??, 2008 - What the heck did I do???  Apparently some time in late 2008, I did some experiments
                         on this program, but I never wrote notes on them here.  Specifically, I seem to have
                         moved Flags, Arguments, and Stats from global to local-to-main.  How is that going
                         to work with the current implimentation of RecursionDecider() and CursDirs?
      Thu Mar 19, 2009 - Renamed "Flags_t" to "Bools_t" and "Flags" to "Bools".  I'm seeing now what I did
                         late last year.  Instead of feeding a void-void "ProcessCurrentDirectory" function
                         to RecursionDecider(), main() now calls function DedupNewsbinFiles(), which calls
                         function LoadFileNameMap(), which feeds "TreeMap(M, Keys)()" to CursDirs().
                         A functor application operator!  Now I see what I did!  Charming, actually.
                         I can see now that this approach has several advantages:
                           1. Gets rid of all global variables.
                           2. Keeps all program-wide data in local variables in main().
                           3. Gives a suitable void-void-function-like thingy to feed to CursDirs().
                           4. Takes full advantage of CursDirs()'s flexibility as a template.
      Thu Mar 19, 2009 - Split program into two programs:
                           1. "DeDup Newsbin Multi" (cross-folder or cross-drive)
                           2. "DeDup Newsbin Files" (one folder at a time)
                         Next work that needs to be done is getting the cross-drive dudup feature working
                         better.  Specifically, it's *NOT* acceptable to erase files in "permanant"
                         directories in favor of files in temp or presort directories!  This must be fixed.
      Thu Mar 19, 2009 - QUESTION: what does bBeast do?
*/

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

#include <unistd.h>

// define or undef BLAT_ENABLE here to enable/disable debug output macro
// "BLAT", located in rhutil.h (obviously, this line must come BEFORE
// the line that includes rhutil.h):
#undef  BLAT_ENABLE
#define BLAT_ENABLE

#include "rhutil.hpp"
#include "rhdir.hpp"

namespace ns_DedupNewsbin
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

   struct Bools_t   // program boolean settings
   {
      bool bBeast;  // Delete older file if enumerated "-(6666)".
      bool bCurse;  // Recursively traverse directory tree downward from current node.
      bool bMulti;  // Span multiple hard drives.
      bool bDrivD;  // Include drive D in multi-drive recursion.
      bool bDrivE;  // Include drive E in multi-drive recursion.
      bool bDrivF;  // Include drive F in multi-drive recursion.
      bool bDrivG;  // Include drive G in multi-drive recursion.
   };

   struct Stats_t   // program run-time statistics
   {
      uint32_t  DirCount;
      uint32_t  GrpCount;
      uint32_t  FilCount;
      uint32_t  DelCount;
   };

   class TreeMap
   {
      public:
         TreeMap(FRM & M, LS & Keys) : M_(M), Keys_(Keys) {}
         void operator()(void); // defined below
      private:
         FRM  &  M_;
         LS   &  Keys_;
   };


   // Function Prototypes:

   void
   ProcessArguments
   (
      VS           const  &  Flags,
      VS           const  &  Arguments,
      Bools_t             &  Bools
   );

   inline
   bool
   InVec
   (
      VS           const  &  Vec,
      std::string  const  &  Txt
   );

   void
   DedupNewsbinFiles
   (
      Bools_t      const  &  Bools,
      Stats_t             &  Stats
   );

   int
   EradicateDuplicates
   (
      FRM                 &  M,             // The Multimap.
      std::string  const  &  Key,           // Key of current file group.
      Bools_t      const  &  Bools,         // Program flags.
      Stats_t             &  Stats          // Program statistics.
   );

   void
   LoadFileNameMap
   (
      FRM                 &  M,
      LS                  &  Keys,
      Bools_t      const  &  Bools,
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
   using namespace ns_DedupNewsbin;

   BLAT("\nIn program dedup-newsbin-files, function main().")
   BLAT("At top of main().  About to run HelpDecider.\n")

   // If command line contains "--help" or "-h" give instructions then return:
   if (rhutil::HelpDecider(Beren, Luthien, Help)) {return 777;}

   BLAT("\nIn program dedup-newsbin-files, function main().")
   BLAT("Finished with help decider; about to declare variables.\n");

   VS       Flags;       // Program flag arguments other than -r, --recurse, -h, --help.
   VS       Arguments;   // Program non-flag arguments.
   Bools_t  Bools;       // Program boolean settings.
   Stats_t  Stats;       // Runtime statistics.

   BLAT("\nIn program dedup-newsbin-files, function main().")
   BLAT("Finished declaring variables; about to get Flags and Arguments.\n");

   // Get Flags and Arguments:
   rhutil::GetFlags     ( Beren, Luthien, Flags     );
   rhutil::GetArguments ( Beren, Luthien, Arguments );

   BLAT("\nIn program dedup-newsbin-files, function main().")
   BLAT("Finished getting Flags and Arguments; about to process arguments.\n");

   // Set Bools based on arguments:
   ProcessArguments(Flags, Arguments, Bools);

   BLAT("\nIn program dedup-newsbin-files, function main().")
   BLAT("Finished getting system-state flags; about to run DedupNewsbinFiles().\n");

   // Run DedupNewsbinFiles():
   DedupNewsbinFiles(Bools, Stats);

   BLAT("\nIn program dedup-newsbin-files, function main().")
   BLAT("Finished with DedupNewsbinFiles().  About to run PrintStats().\n");

   // Print statistics (counts of directories processed, files processed,
   // files renamed, and files erased):
   PrintStats(Stats);

   BLAT("\nIn program dedup-newsbin-files, function main().")
   BLAT("Finished with PrintStats().  About to return from main().\n");

   // If we get to here without having crashed and burned, return 0:
   return 0;

} // End main()



/////////////////////////////////////////////////////////////////////////////////////
//                                                                                 //
//  Process Arguments()                                                            //
//                                                                                 //
//  Sets program-state booleans based on flags and arguments.                      //
//                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////

void
ns_DedupNewsbin::
ProcessArguments
   (
      VS       const  &  Flags,
      VS       const  &  Arguments,
      Bools_t         &  Bools
   )
{
   // Use InVec from rhutil:
   using rhutil::InVec;

   // Start with Bools.bMulti set to false; it may get set to true below:
   Bools.bMulti = false;

   // Get bCurse and bBeast:
   Bools.bCurse = InVec(Arguments, "-r") || InVec(Arguments, "--recurse");
   Bools.bBeast = InVec(Arguments, "-b") || InVec(Arguments, "--beast"  );

   // Set the bDriv? bools to true iff Arguments contains the corresponding drive letters.
   // Furthermore, set bMulti to true iff Arguments contains *any* drive letters.
   if (InVec(Arguments, "D")) {Bools.bMulti = true; Bools.bDrivD = true;}
   if (InVec(Arguments, "E")) {Bools.bMulti = true; Bools.bDrivE = true;}
   if (InVec(Arguments, "F")) {Bools.bMulti = true; Bools.bDrivF = true;}
   if (InVec(Arguments, "G")) {Bools.bMulti = true; Bools.bDrivG = true;}

   // WOMBAT RH 2009-03-19: I just erased drive letters H, I, J, K because they no longer correspond
   // to existing logical drives on my computer.  I should really find some way of determining which
   // drive letters are valid; but for now, drives D,E,F,G should do just fine.

   return;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//  DedupNewsbinFiles()                                                                                     //
//                                                                                                          //
//  1. Load file records for all files in current   tree    into multimap<FileRecord> M, keyed by                //
//     name root (see "definitions" section at top of this file).                                           //
//  2. In the process of loading M, also record the name roots of any candidate files found into            //
//     list<string> L.                                                                                      //
//  3. For each name root R in L, run function EradicateDuplicates().                                       //
//                                                                                                          //
//  (Note that only those file-groups in M for which corresponding name-root entries exist in L are         //
//  processed.  Since only file names that contain "-(####)" substrings will generate entries in L, most    //
//  files will NOT be processed, which dramatically speeds program execution.)                              //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

void
ns_DedupNewsbin::
DedupNewsbinFiles
      (
         Bools_t      const  &  Bools,
         Stats_t             &  Stats
      )
{
   BLAT("Just entered ns_DedupNewsbin::DedupNewsbinFiles().");

   // Make a multimap of file records in this tree, keyed by root file name:
   std::multimap<std::string, rhdir::FileRecord> M;

   // Make a list of root file names:
   std::list<std::string> Keys;

   // Load file records for all files in this directory into M,
   // and load all candidate root file names into L:

   BLAT("About to execute LoadFileNameMap(M, Keys, Bools, Stats); ...");

   LoadFileNameMap(M, Keys, Bools, Stats);

   BLAT("finished executing LoadFileNameMap(M, Keys, Bools, Stats);")

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
      ++Stats.GrpCount;
      BLAT("Name group #" << Stats.GrpCount << ", files with name root \"" << (*i) << "\":")

      // For each file in this name group, increment global counter FilCount:
      for (FRMI Current = M.lower_bound(*i); Current != M.upper_bound(*i); ++Current)
      {
         ++Stats.FilCount;
         BLAT("   " << Current->second.name)
      }

      // Search for pairs of duplicate files in this group; for each such pair found, erase the newer:
      BLAT("In ns_DedupNewsbin::DedupNewsbinFiles(), "
         "about to call ns_DedupNewsbin::EradicateDuplicates().")
      EradicateDuplicates(M, *i, Bools, Stats);
      BLAT("In ns_DedupNewsbin::DedupNewsbinFiles(), "
         "just returned from ns_DedupNewsbin::EradicateDuplicates().")

   } // end for (each key in L)

   BLAT("About to return from ns_DedupNewsbin::DedupNewsbinFiles().")
   return;

} // end function void ns_DedupNewsbin::DedupNewsbinFiles(void)


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
ns_DedupNewsbin::
LoadFileNameMap
   (
      FRM             &  M,
      LS              &  Keys,
      Bools_t  const  &  Bools,
      Stats_t         &  Stats
   )
{
   // Clear M and Keys:
   M.clear();
   Keys.clear();

   // Make a TreeMap object:
   TreeMap TMap (M, Keys);

   // If doing cross-drive recursion, collect all file info from all listed drives:
   if (Bools.bMulti)
   {
      if (Bools.bDrivD)
      {
         system ("D:");
         system ("cd \\");
         Stats.DirCount += rhdir::CursDirs(TMap);
      }
      if (Bools.bDrivE)
      {
         system ("E:");
         system ("cd \\");
         Stats.DirCount += rhdir::CursDirs(TMap);
      }
      if (Bools.bDrivF)
      {
         system ("F:");
         system ("cd \\");
         Stats.DirCount += rhdir::CursDirs(TMap);
      }
      if (Bools.bDrivG)
      {
         system ("G:");
         system ("cd \\");
         Stats.DirCount += rhdir::CursDirs(TMap);
      }
   }

   // Else if doing cross-directory recursion, recursively descend tree from current node:
   else if (Bools.bCurse)
   {
      Stats.DirCount = rhdir::CursDirs(TMap);
   }

   // Otherwise, process current directory only:
   else
   {
      TMap();
      Stats.DirCount = 1;
   }

   return;
} // end ns_DedupNewsbin::LoadFileNameMap()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  TreeMap::operator()()                                                   //
//                                                                          //
//  Loads all file names in current directory into a std::multimap of       //
//  rhdir::FileRecord's keyed by "root file name" (the file name minus any  //
//  "-(3867)" additions from NewsBin).  Also keeps track of all "candidate" //
//  root file names in a separate list.                                     //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_DedupNewsbin::
TreeMap::
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

   BLAT("Just entered ns_DedupNewsbin::TreeMap::operator().")

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
      BLAT("In ns_DedupNewsbin::TreeMap::operator();")
      BLAT("about to call ns_DedupNewsbin::IsPathological().")
      bool bPath = ns_DedupNewsbin::IsPathological(File_Name);
      BLAT("In ns_DedupNewsbin::TreeMap::operator();")
      BLAT("just returned from ns_DedupNewsbin::IsPathological().")
      if (bPath)
      {
         cerr
            << "Warning: file name " << File_Name << " is pathological." << endl
            << "Skipping to next file." << endl;
         continue;
      }

      // Get the name root for this file name by stripping-out all instances of "-(####)" substrings
      // from current file name and converting result to all-lower-case to prevent duplicates:

      BLAT("In ns_DedupNewsbin::TreeMap::operator(), about to call rhdir::Denumerate().")
      Name_Root = rhutil::StringToLower(rhdir::Denumerate(File_Name));
      BLAT("In ns_DedupNewsbin::TreeMap::operator(), just returned from rhdir::Denumerate().")
      BLAT("Name Root:   " << Name_Root)
      BLAT("File Record: " << File_Record)

      // Insert the current file name into M, keyed by name root:
      M_.insert(std::make_pair(Name_Root, File_Record));

      // If current file name is a candidate, push it's name root onto our stack of name roots for which
      // associated candidate files exist:
      if (ns_DedupNewsbin::IsCandidate(File_Name))
      {
         Keys_.push_back(Name_Root);
      }
   }

   // Now that all of the files in the current directory have been processed, sort and dedup Keys:
   rhutil::SortDup(Keys_);

   // Return to calling function:
   BLAT("About to return from TreeMap::operator().")
   return;
} // end void ns_DedupNewsbin::TreeMap::operator()(void)


/////////////////////////////////////////////////////////////////////////////////////
//                                                                                 //
//  EradicateDuplicates()                                                          //
//                                                                                 //
//  Erases all duplicate files in current file name group.                         //
//                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////

int
ns_DedupNewsbin::
EradicateDuplicates
      (
         FRM                &  M,             // The Multimap.
         std::string const  &  Key,           // Key of current file group.
         Bools_t     const  &  Bools,         // Program flags.
         Stats_t            &  Stats          // Program statistics.
      )
{
   BLAT("Just entered ns_DedupNewsbin::EradicateDuplicates().")

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
               BLAT("In ns_DedupNewsbin::EradicateDuplicates(), skipping to next file because "
                  "bSizeMatch is false.")
               continue;
            }

            // If files aren't identical, continue to next "Compare" file:
            bool bIdentical = rhdir::FilesAreIdentical(Current->second.path(), Compare->second.path());
            BLAT("bIdentical = " << std::boolalpha << bIdentical);
            if (!bIdentical)
            {
               BLAT("In ns_DedupNewsbin::EradicateDuplicates(), skipping to next file because "
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


            // If (Bools.bBeast and (older file name contains "-(6666)") ), erase older file:
            if (Bools.bBeast and std::string::npos != OlderFile.name.find("-(6666)"))
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

   BLAT("About to return from ns_DedupNewsbin::EradicateDuplicates().")
   return 0;

} // end EradicateDuplicates()


//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
//  IsPathological()                                                                    //
//  Decides whether or not a file name is "pathological"; that is, whether the prefix   //
//  and/or suffix would be empty if all numerators are removed.                         //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

bool
ns_DedupNewsbin::
IsPathological
      (
         std::string const & Name
      )
{
   BLAT("Just entered ns_DedupNewsbin::IsPathological().")

   BLAT("In ns_DedupNewsbin::IsPathological(), about to call rhdir::Denumerate().")
   std::string StrippedName = rhdir::Denumerate(Name);
   BLAT("In ns_DedupNewsbin::IsPathological(), just returned from rhdir::Denumerate().")

   std::string Prefix = rhdir::GetPrefix(StrippedName);
   std::string Suffix = rhdir::GetSuffix(StrippedName);
   if (Prefix.empty() || Suffix.empty())
   {
      BLAT("About to return true from ns_DedupNewsbin::IsPathological().")
      return true;
   }
   else
   {
      BLAT("About to return false from ns_DedupNewsbin::IsPathological().")
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
ns_DedupNewsbin::
IsCandidate
      (
         std::string const & Name
      )
{
   BLAT("Just entered ns_DedupNewsbin::IsCandidate().")

   // If name is pathological, file is not a candidate:
   BLAT("In ns_DedupNewsbin::IsCandidate(), about to call ns_DedupNewsbin::IsPathological().")
   bool bPatho = ns_DedupNewsbin::IsPathological(Name);
   BLAT("In ns_DedupNewsbin::IsCandidate(), just returned from ns_DedupNewsbin::IsPathological().")
   if (bPatho)
   {
      BLAT("About to return false from ns_DedupNewsbin::IsCandidate() because file name is pathological.")
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
         BLAT("About to return true from ns_DedupNewsbin::IsCandidate().")
         return true;
      }
   }

   BLAT("About to return false from ns_DedupNewsbin::IsCandidate().")
   return false;
}


///////////////////////////////////////////////////////
//                                                   //
//  PrintStats()                                     //
//  Print statistics.                                //
//                                                   //
///////////////////////////////////////////////////////

void
ns_DedupNewsbin::
PrintStats
      (
         Stats_t  const  &  Stats
      )
{
   cout
      << endl
      << endl
      << "Directories processed:    " << Stats.DirCount   << endl
      << "Name groups examined:     " << Stats.GrpCount << endl
      << "Files examined:           " << Stats.FilCount  << endl
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
ns_DedupNewsbin::
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
