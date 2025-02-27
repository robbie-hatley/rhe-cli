/*
   Program Name:         DeDup Newsbin Files
   File name:            dedup-newsbin-files.cpp
   Source for:           dedup-newsbin-files.exe
   Author:               Robbie Hatley
   Date written:         Thu Jan 02, 2003
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

      "numerated file":
         A file with a name which contains one or more numerators.  (Eg: "djtyw-(1948).txt" is a
         "numerated file", but "djtyw-(194).txt", "djtyw-(19456).txt", and "djtyw.txt" are not.)

      "pathological file":
         A file with a name which, if all numerators are removed, has an empty prefix and/or an empty suffix.
         (Eg: "-(3958).spc", "spc.-(9384)", "-(9975).-(2048)", and "-(2358)" are all pathological files.)

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

      "candidate":
         A non-pathological file which is either numerated, or has the same name root as a numerated file in
         the same directory.  For example, if a directory contains the following files:
         1. "foeslj.mp3"
         2. "pqskdiwt.jpg"
         3. "eosktusk-(3856).txt"
         4. "foeslj-(0001).mp3"
         5. "eosktusk.txt"
         Then files 1,3,4,5 are "candidates", but file 2 is not.

      "name group":
         A group of non-pathological files with the same name root.

      "NCS_Equal":
         Two strings are "NCS_Equal" if they are non-case-sensitively equal.  Eg, "RaT" and "rAt" are
         NCS_Equal.

      "Erase-Older-File Mode":
         The mode entered into by using a "-o" or "--older" switch on the command line.
         (See the next paragraph, "Pragmatology", for more on this.)


   Pragmatology (what this program does):
      For each file in the current directory:
         If the file is pathological:
            Print an alert and bypass that file.
         Otherwise:
            If the file is a candidate:
               Compare the file to each candidate in the same name group.
               For each pair of duplicates found:
                  If in Erase-Older-File Mode:
                     erase the older file
                  Otherwise:
                     erase the newer file
            Otherwise:
               Do nothing.


   Methodology (how this program goes about accomplishing the above):
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
                         For each pair of duplicate files, the newer file is erased, unless we're in
                         Erase-Older-File Mode, in which case the older file is erased.
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
      Thu Mar 19, 2009 - BUT!!!!!  I find now that I detest the whole idea of forcing cross-folder
                         deduping.  I mostly don't want this, because I like to keep copies of files
                         in multiple locations on purpose.  So I'm spliting the program into 2 programs:
                           1. "DeDup Newsbin Multi" (cross-folder or cross-drive)
                           2. "DeDup Newsbin Files" (one folder at a time)
                         Now, I need to get *THIS* version back to non-cross-dedup.  Grrr.
      Thu Mar 19, 2009 - QUESTION: what does bBeast do?
      Sun May 03, 2009 - ANSWER: beast mode erases older duplicates instead of newer, provided that the
                         name of the older file contains the "number of the beast" numerator, "-(6666)".
                         To invoke beast mode, mark old files for deletion-if-duplicate with "-(6666)",
                         then type "dedup-newsbin-files -b".  One reason for doing this might be to get
                         rid of annoying FILE NAMES IN ALL CAPITAL LETTERS left over from the DOS days,
                         provided that newer duplicates with NCS_Equal but small-letter names exist.
                         Another reason might be to keep track of the most RECENT file dates rather than
                         the most ANCIENT file dates.
      Sun May 03, 2009 - Added "quiet" mode, using switch "-q" or "--quiet".  (Prints final stats only.)
                         Also I now bypass EradicateDuplicates() if there are fewer than 2 files in a
                         file name group.  Also, updated and cleaned-up Help(), and added the above
                         explanation for beast mode.
      Tue May 05, 2009 - I got sick and tired of every name group being displayed as it's processed
                         (it clogs the output buffer or log file with vast ammounts of useless garbage)
                         so I removed the code that outputs name groups.  That should make it a lot
                         easier to see the directory headings (which tell progress during recursive
                         deduping) and file deletions.
      Tue May 05, 2009 - I also changed "Beast Mode" to "Erase-Older-File Mode", and -b|--beast to
                         -o|--older.

*/

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

// To    use    asserts, #undef  NDEBUG.
// To *not* use asserts, #define NDEBUG.
// (This must be done BEFORE #including <assert.h>.  Obviously.)
#define NDEBUG
#undef NDEBUG

#include <assert.h>

// To    use    BLAT, #define BLAT_ENABLE.
// To *not* use BLAT, #undef  BLAT_ENABLE.
// (This must be done BEFORE #including any of my personal library headers.  Obviously.)
#define BLAT_ENABLE
#undef  BLAT_ENABLE

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
      Bools_t (void)
         :
         bOlder (false), bCurse (false), bQuiet (false), bMulti (false),
         bDrivD (false), bDrivE (false), bDrivF (false), bDrivG (false),
         bDrivH (false), bDrivI (false), bDrivJ (false), bDrivK (false)
         {}
      bool bOlder;  // Delete older file instead of newer.
      bool bCurse;  // Recursively traverse directory tree downward from current node.
      bool bQuiet;  // Be quiet.
      bool bMulti;  // Span multiple hard drives.  (Not currently used.)
      bool bDrivC;  // Include drive C in multi-drive recursion.
      bool bDrivD;  // Include drive D in multi-drive recursion.
      bool bDrivE;  // Include drive E in multi-drive recursion.
      bool bDrivF;  // Include drive F in multi-drive recursion.
      bool bDrivG;  // Include drive G in multi-drive recursion.
      bool bDrivH;  // Include drive H in multi-drive recursion.
      bool bDrivI;  // Include drive I in multi-drive recursion.
      bool bDrivJ;  // Include drive J in multi-drive recursion.
      bool bDrivK;  // Include drive K in multi-drive recursion.
   };

   class Stats_t   // program run-time statistics
   {
      public:
         Stats_t (void)
            :
            DirCount(0), GrpCount(0), FilCount(0), DelCount(0)
            {}
         void IncDirCount (void) {++DirCount;}
         void IncGrpCount (void) {++GrpCount;}
         void IncFilCount (void) {++FilCount;}
         void IncDelCount (void) {++DelCount;}
         uint32_t GetDirCount (void) {return DirCount;}
         uint32_t GetGrpCount (void) {return GrpCount;}
         uint32_t GetFilCount (void) {return FilCount;}
         uint32_t GetDelCount (void) {return DelCount;}
         void PrintStats  (void)
         {
            cout
               << endl
               << endl
               << "Directories processed:    " << DirCount << endl
               << "Name groups examined:     " << GrpCount << endl
               << "Files examined:           " << FilCount << endl
               << "Duplicate files deleted:  " << DelCount << endl;
            return;
         }
      private:
         uint32_t  DirCount;
         uint32_t  GrpCount;
         uint32_t  FilCount;
         uint32_t  DelCount;
   };

   class DedupCurDir
   {
      public:
         DedupCurDir(Bools_t const & Bools, Stats_t & Stats)
            : Bools_(Bools), Stats_(Stats) {}
         void operator()(void); // defined below
      private:
         Bools_t const & Bools_;
         Stats_t       & Stats_;
   };


   // Function Prototypes:

   void
   ProcessArguments
   (
      VS           const  &  Flags,
      VS           const  &  Arguments,
      Bools_t             &  Bools
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
      std::string  const  &  CurrDir
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

   BLAT("\nJust entered main().  About to run HelpDecider.\n")

   // If command line contains "--help" or "-h" give instructions then return:
   if (rhutil::HelpDecider(Beren, Luthien, Help)) {return 777;}

   BLAT("\nIn main(), finished with help decider; about to declare variables.\n");

   VS       Flags;               // Program flag arguments.
   VS       Arguments;           // Program non-flag arguments.
   Bools_t  Bools = Bools_t ();  // Program boolean settings.
   Stats_t  Stats = Stats_t ();  // Runtime statistics.

   BLAT("\nIn main(), finished declaring variables.")
   BLAT("Here's the initialized values of the stats, before they're altered:")
   BLAT("DirCount = " << Stats.GetDirCount())
   BLAT("GrpCount = " << Stats.GetGrpCount())
   BLAT("FilCount = " << Stats.GetFilCount())
   BLAT("DelCount = " << Stats.GetDelCount())
   BLAT("About to get Flags and Arguments.\n");

   // Get Flags and Arguments:
   rhutil::GetFlags     ( Beren, Luthien, Flags     );
   rhutil::GetArguments ( Beren, Luthien, Arguments );

   BLAT("\nIn main(), finished getting Flags and Arguments; about to process arguments.\n");

   // Set Bools based on arguments:
   ProcessArguments(Flags, Arguments, Bools);

   BLAT("\nIn main().  Finished processing args, about to run DedupNewsbinFiles().\n");

   // Run DedupNewsbinFiles():
   DedupNewsbinFiles(Bools, Stats);

   BLAT("\nIn main(), finished with DedupNewsbinFiles(), about to run PrintStats().\n");

   // Print statistics (counts of directories processed, files processed,
   // files renamed, and files erased):
   Stats.PrintStats();

   BLAT("\nIn main(), finished with PrintStats(), about to return from main().\n");

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

   BLAT("\nJust entered ProcessArguments().  About to set Bools.\n")

   // Set bools based on flags:
   Bools.bCurse = InVec(Flags, "-r") || InVec(Flags, "--recurse");
   Bools.bOlder = InVec(Flags, "-o") || InVec(Flags, "--older"  );
   Bools.bQuiet = InVec(Flags, "-q") || InVec(Flags, "--quiet"  );

   // Set Bools.bMulti set to false here; it may get set to true below:
   Bools.bMulti = false;

   // Set the bDriv? bools to true iff Arguments contains the corresponding drive letters.
   // Furthermore, set bMulti to true iff Arguments contains *any* drive letters.
   if (InVec(Arguments, "C")) {Bools.bMulti = true; Bools.bDrivC = true;}
   if (InVec(Arguments, "D")) {Bools.bMulti = true; Bools.bDrivD = true;}
   if (InVec(Arguments, "E")) {Bools.bMulti = true; Bools.bDrivE = true;}
   if (InVec(Arguments, "F")) {Bools.bMulti = true; Bools.bDrivF = true;}
   if (InVec(Arguments, "G")) {Bools.bMulti = true; Bools.bDrivG = true;}
   if (InVec(Arguments, "H")) {Bools.bMulti = true; Bools.bDrivH = true;}
   if (InVec(Arguments, "I")) {Bools.bMulti = true; Bools.bDrivI = true;}
   if (InVec(Arguments, "J")) {Bools.bMulti = true; Bools.bDrivJ = true;}
   if (InVec(Arguments, "K")) {Bools.bMulti = true; Bools.bDrivK = true;}

   // WOMBAT RH 2009-05-05: I'm currently allowing drive letters C-K, even though I don't
   // really want to be deduping drive C, drives H-I are temporary, and drives J-K don't
   // actually exist.  But I'd rather be flexible and extensible, even if that means
   // including more drive letters than I'll use.  (I should really find some way of determining
   // which drive letters are valid; but for now, drives C-K should do just fine.)

   BLAT("\nAt bottom of ProcessArguments().")
   BLAT("Bools.bCurse = " << Bools.bCurse)
   BLAT("Bools.bOlder = " << Bools.bOlder)
   BLAT("Bools.bQuiet = " << Bools.bQuiet)
   BLAT("Bools.bMulti = " << Bools.bMulti)
   BLAT("Bools.bDrivC = " << Bools.bDrivC)
   BLAT("Bools.bDrivD = " << Bools.bDrivD)
   BLAT("Bools.bDrivE = " << Bools.bDrivE)
   BLAT("Bools.bDrivF = " << Bools.bDrivF)
   BLAT("Bools.bDrivG = " << Bools.bDrivG)
   BLAT("Bools.bDrivH = " << Bools.bDrivH)
   BLAT("Bools.bDrivI = " << Bools.bDrivI)
   BLAT("Bools.bDrivJ = " << Bools.bDrivJ)
   BLAT("Bools.bDrivK = " << Bools.bDrivK)
   BLAT("About to return from ProcessArguments.\n")

   return;
} // end ns_DedupNewsbin::ProcessArguments()


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//  DedupNewsbinFiles()                                                                                     //
//                                                                                                          //
//  1. Load file records for all files in current directory into multimap<FileRecord> M, keyed by           //
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
   BLAT("\nJust entered DedupNewsbinFiles(), about to make a DedupCurDir object.\n");

   // Make a DedupCurDir object:
   DedupCurDir DnsCurDir(Bools, Stats);

   BLAT("\nIn DedupNewsbinFiles(), made DnsCurDir, about to walk drives and/or dirs.\n")

   // If doing multi-drive (*NOT* cross-drive!!!) recursion, set current drive to each of the requested
   // drives in turn, and send DnsCurDir to CursDirs() for each requested drive:
   if (Bools.bMulti)
   {
      if (Bools.bDrivC)
      {
         chdir("C:/");
         rhdir::CursDirs(DnsCurDir);
      }
      if (Bools.bDrivD)
      {
         chdir("D:/");
         rhdir::CursDirs(DnsCurDir);
      }
      if (Bools.bDrivE)
      {
         chdir ("E:/");
         rhdir::CursDirs(DnsCurDir);
      }
      if (Bools.bDrivF)
      {
         chdir("F:/");
         rhdir::CursDirs(DnsCurDir);
      }
      if (Bools.bDrivG)
      {
         chdir("G:/");
         rhdir::CursDirs(DnsCurDir);
      }
      if (Bools.bDrivH)
      {
         chdir("H:/");
         rhdir::CursDirs(DnsCurDir);
      }
      if (Bools.bDrivI)
      {
         chdir ("I:/");
         rhdir::CursDirs(DnsCurDir);
      }
      if (Bools.bDrivJ)
      {
         chdir("J:/");
         rhdir::CursDirs(DnsCurDir);
      }
      if (Bools.bDrivK)
      {
         chdir("K:/");
         rhdir::CursDirs(DnsCurDir);
      }
   }

   // Else if doing multi-directory (*NOT* cross-directory!!!) recursion, leave current drive and
   // directory set to what they are, and send DnsCurDir to CursDirs():
   else if (Bools.bCurse)
   {
      rhdir::CursDirs(DnsCurDir);
   }

   // Otherwise, process current directory only:
   else
   {
      DnsCurDir();
   }

   BLAT("\nAt bottom of DedupNewsbinFiles(), about to return.\n")

   return;
} // end function void ns_DedupNewsbin::DedupNewsbinFiles(void)


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  DedupCurDir::operator()()                                               //
//                                                                          //
//  Processes current directory.  Calls functions which map the file        //
//  records of all files in the current direcory by name root, store the    //
//  name roots of the candidates in a list, and delete all duplicate        //
//  candidates in the current directory.  (See "Definitions" at the top of  //
//  this file for the definitions of "name root" and "candidate".)          //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_DedupNewsbin::
DedupCurDir::
operator()
   (
      void
   )
{
   BLAT("\nJust entered DedupCurDir::operator().")
   BLAT("Here's the Stats on entry, before this function alters them:")
   BLAT("Stats_.DirCount = " << Stats_.GetDirCount())
   BLAT("Stats_.GrpCount = " << Stats_.GetGrpCount())
   BLAT("Stats_.FilCount = " << Stats_.GetFilCount())
   BLAT("Stats_.DelCount = " << Stats_.GetDelCount())
   BLAT("About to increment Stats_.DirCount.\n")

   // Another day, another directory:
   Stats_.IncDirCount();

   BLAT("\nIn DedupCurDir::operator(), just incremented Stats_.DirCount.")
   BLAT("About to get CurrDir, and announce both Stats_.DirCount and CurrDir.\n");

   // Get curr. dir.:
   std::string CurrDir ( rhdir::GetFullCurrPath() );

   // If not being quiet, announce directory # and CurrDir:
   if (!Bools_.bQuiet)
   {
      cout
                                                                                        << endl
         << "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"  << endl
         << "Directory #" << Stats_.GetDirCount() << ":"                                << endl
         << CurrDir                                                                     << endl;
   }

   BLAT("\nIn DedupCurDir::operator(), just announced DirCount and CurrDir.")
   BLAT("About to make multimap \"M\" and list \"Keys\".\n");

   // Make a multimap of file records in this tree, keyed by root file name:
   std::multimap<std::string, rhdir::FileRecord> M;

   // Make a list of root file names:
   std::list<std::string> Keys;

   BLAT("\nIn DedupCurDir::operator().")
   BLAT("Finished making multimap \"M\" and list \"Keys\".")
   BLAT("About to execute LoadFileNameMap().\n");

   // Load file records for all files in this directory into M,
   // and load all candidate root file names into L:
   LoadFileNameMap(M, Keys, CurrDir);

   BLAT("\nIn DedupCurDir::operator().")
   BLAT("Finished executing LoadFileNameMap().")
   BLAT("Map  size = " << M.size())
   BLAT("Keys size = " << Keys.size() << "\n")

   // If M.size() is less than 2, this tree cannot contain duplicates, so return:
   if (M.size() < 2) {return;}

   // If we get to here, this directory has at least 2 files in it, so iterate through our list of
   // root file names, and examine ONLY those name groups in M which are keyed by names in Keys.
   // (This should save ENORMOUS amounts of time compared to how I WAS doing it!)

   // For each name group (ie, for each key in Keys):
   std::string Key;
   int NameGroupFileCount;
   for (LSI i = Keys.begin(); i != Keys.end(); ++i)
   {
      Key = (*i);

      // Assert that a group in M with current key actually does exist:
      assert(M.lower_bound(Key) != M.end());

      // Assert that this group is not empty:
      assert(M.upper_bound(Key) != M.lower_bound(Key));

      // If we get to here, we're processing a non-empty group,
      // so increment the group counter:
      Stats_.IncGrpCount();

      // For each file in this name group, increment global counter FilCount
      // and local counter NameGroupFileCount:
      NameGroupFileCount = 0;
      for (FRMI Current = M.lower_bound(*i); Current != M.upper_bound(*i); ++Current)
      {
         BLAT("Counting file: " << Current->second.name)
         ++NameGroupFileCount;
         Stats_.IncFilCount();
      }

      BLAT("\nIn DedupCurDir::operator(), in \"for each key\" loop.")
      BLAT("About to check to see if there's 2 or more files.\n")

      // Provided that there are 2 or more files in this name group, search for pairs
      // of duplicate files in this group; for each such pair found, erase the newer
      // (or the older, if in Erase-Older-File Mode):
      if (NameGroupFileCount >= 2)
      {
         BLAT("\nIn DedupCurDir::operator().  There are 2 or more files in this group,")
         BLAT("so we're about to call EradicateDuplicates().\n")
         EradicateDuplicates(M, *i, Bools_, Stats_);
         BLAT("\nIn DedupCurDir::operator().  Just returned from EradicateDuplicates().\n")
      }

      // Otherwise, do nothing.
      else
      {
         BLAT("\nIn DedupCurDir::operator().  There are less than 2 files in this group,")
         BLAT("so we're bypassing EradicateDuplicates().\n")
         ; // Do nothing.
      }

      BLAT("\nIn DedupCurDir::operator(), at bottom of \"for each key\" loop.\n")
   } // end for (each key in L)

   BLAT("\nAt end of DedupCurDir::operator().")
   BLAT("Here's the stats after this function altered them:")
   BLAT("Stats_.DirCount = " << Stats_.GetDirCount())
   BLAT("Stats_.GrpCount = " << Stats_.GetGrpCount())
   BLAT("Stats_.FilCount = " << Stats_.GetFilCount())
   BLAT("Stats_.DelCount = " << Stats_.GetDelCount())
   BLAT("About to return from DedupCurDir::operator().\n")
   return;
} // end ns_DedupNewsbin::DedupCurDir::operator()


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
      FRM                 &  M,
      LS                  &  Keys,
      std::string  const  &  CurrDir
   )
{
   ffblk              File_Block    = ffblk();
   rhdir::FileRecord  File_Record   = rhdir::FileRecord();
   std::string        File_Name     = std::string();
   std::string        Name_Root     = std::string();
   int                done          = 0;

   BLAT("\nJust entered LoadFileNameMap().  About to run Untilde().\n")

   // To prevent problems with file renames, deletions, and comparisons, change all tildes in file names
   // in current directory into underscores:
   rhdir::UnTilde();

   BLAT("\nIn LoadFileNameMap(), ran Untilde(), about to set File_Flags.\n")

   // Set "File_Flags" variable to accept all files and directories except volume lables:
   uint8_t File_Flags ( FA_RDONLY | FA_HIDDEN | FA_SYSTEM | FA_ARCH );

   BLAT("\nIn LoadFileNameMap(), finished setting File_Flags.")
   BLAT("File_Flags = " << File_Flags)
   BLAT("About to enter for loop.\n")

   // Search for all files, but not directories or volume labels, in current directory:
   for (done = findfirst("*", &File_Block, File_Flags) ; not done ; done = findnext(&File_Block))
   {
      // Get file record from file block:
      File_Record = rhdir::FileRecord(File_Block, CurrDir);

      // Get file name from file record:
      File_Name = File_Record.name;

      BLAT("\nIn LoadFileNameMap(), in for loop.")
      BLAT("Retrieved a file name from the directory: " << File_Name)
      BLAT("About to call ns_DedupNewsbin::IsPathological().\n")

      // Is this file name pathological?
      bool bPath = ns_DedupNewsbin::IsPathological(File_Name);

      BLAT("\nIn LoadFileNameMap(), in for loop, back from IsPathological().")
      BLAT("About to print warning if bPath is true.\n")

      if (bPath)
      {
         cerr
            << "Warning: file name " << File_Name << " is pathological." << endl
            << "Skipping to next file." << endl;
         continue;
      }

      BLAT("\nIn LoadFileNameMap(), printed warning if bPath was true.")
      BLAT("About to get Name_Root.\n")

      // Get the name root for this file name by stripping-out all instances of "-(####)" substrings
      // from current file name and converting result to all-lower-case to prevent duplicates:
      Name_Root = rhutil::StringToLower(rhdir::Denumerate(File_Name));

      BLAT("\nIn LoadFileNameMap(), finished getting Name_Root.")
      BLAT("name root: " << Name_Root)
      BLAT("file name: " << File_Name)
      BLAT("About to insert std::make_pair(Name_Root, File_Record) into multimap.\n")

      // Insert the current file name into M, keyed by name root:
      M.insert(std::make_pair(Name_Root, File_Record));

      BLAT("\nIn LoadFileNameMap, inserted pair into multimap, about to run \"if\" statement.\n")

      // If current file name is a candidate, push it's name root onto our stack of name roots for which
      // associated candidate files exist:
      if (ns_DedupNewsbin::IsCandidate(File_Name))
      {
         Keys.push_back(Name_Root);
         BLAT("\nIn LoadFileNameMap, in \"if\"; File_Name IS a candidate.\n")
      }
      else
      {
         ; // Do nothing.
         BLAT("\nIn LoadFileNameMap, in \"if\"; File_Name is NOT a candidate.\n")
      }
   }

   BLAT("\nIn LoadFileNameMap, finished with if/else, about to sort keys.\n")

   // Now that all of the files in the current directory have been processed, sort and dedup Keys:
   rhutil::SortDup(Keys);

   BLAT("\nIn LoadFileNameMap, finished sorting keys, about to return.\n")

   return;
} // end ns_DedupNewsbin::LoadFileNameMap()


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
   BLAT("\nJust entered EradicateDuplicates(), about to declare local vars.\n")

   // Define the iterators we'll need:
   FRMI LowerBound;
   FRMI UpperBound;
   FRMI Current;
   FRMI Compare;
   FRMI OlderFile;
   FRMI NewerFile;

   // Make a flag to indicate whether we erased any files during the last comparison loop (ie, the inner
   // "for" loop below):
   bool bErasedFile;

   BLAT("\nIn EradicateDuplicates(), declared local vars, about to enter do loop.\n")

   // Loop at least once, then continue to loop while bErasedFile is true:
   do
   {
      BLAT("\nIn EradicateDuplicates(), at top of do loop.\n")

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
         BLAT("\nIn EradicateDuplicates(), at top of \"for each current file\" loop.")
         BLAT("Name of current file = " << Current->second.name << "\n")

         // See if current file is a duplicate of any file to its right.  If so, delete the newer file,
         // delete its entry in M, set bErasedFile to true, and break out of both inner and outer "for" loops:
         for (Compare = Current, ++Compare; Compare != UpperBound; ++Compare)
         {
            BLAT("\nIn EradicateDuplicates(), at top of \"for each compare file\" loop.")
            BLAT("name of current file = " << Current->second.name)
            BLAT("name of compare file = " << Compare->second.name)
            BLAT("About to check that compare and current are not NCS_Equal.\n")

            // Check that Compare->second.name() is not NCS_Equal to Current->second.name()
            // (ie, we're not about to compare a file to itself!!!):
            if (rhutil::NCS_Equal(Compare->second.name, Current->second.name))
            {
               cerr
               << endl
               << "Error in dedup-newsbin-files.exe, in function EradicateDuplicates():"  << endl
               << "Compare file and Current file are NCS_Equal."                          << endl
               << "Current file name = " << Current->second.name                          << endl
               << "Compare file name = " << Compare->second.name                          << endl
               << "Continuing to next compare file."                                      << endl
               << endl;
               continue;
            }

            BLAT("\nIn EradicateDuplicates(), in \"for each compare file\" loop.")
            BLAT("Finished checking that current and compare are not NCS_Equal.")
            BLAT("About to check that current file actually does exist.\n")

            // Check that the "Current" file actually does exist:
            // (NOTE RH 2009-04-30: I changed from rhdir::FileExists() to __file_exists(),
            // because rhdir::FileExists() seemingly has problems with large dirs.)
            if (!__file_exists(Current->second.name.c_str()))
            {
               cerr
               << endl
               << "Error in dedup-newsbin-files.exe, in function EradicateDuplicates():"  << endl
               << "Current file does not exist!"                                          << endl
               << "Current file name = " << Current->second.name                          << endl
               << "Compare file name = " << Compare->second.name                          << endl
               << "Abandoning this file-name group."                                      << endl
               << "Returning 666 error code from function EradicateDuplicates()."         << endl
               << "Continuing with next file-name group."                                 << endl
               << endl;
               return 666;
            }

            BLAT("\nIn EradicateDuplicates(), in \"for each compare file\" loop.")
            BLAT("Finished checking that current file exists.")
            BLAT("About to check that compare file actually does exist.\n")

            // Check that the "Compare" file actually does exist:
            // (NOTE RH 2009-04-30: I changed from rhdir::FileExists() to __file_exists(),
            // because rhdir::FileExists() seemingly has problems with large dirs.)
            if (!__file_exists(Compare->second.name.c_str()))
            {
               cerr
               << endl
               << "Error in dedup-newsbin-files.exe, in function EradicateDuplicates():"  << endl
               << "Compare file does not exist!"                                          << endl
               << "Current file name = " << Current->second.name                          << endl
               << "Compare file name = " << Compare->second.name                          << endl
               << "Abandoning this file-name group."                                      << endl
               << "Returning 666 error code from function EradicateDuplicates()."         << endl
               << "Continuing with next file-name group."                                 << endl
               << endl;
               return 666;
            }

            BLAT("\nIn EradicateDuplicates(), in \"for each compare file\" loop.")
            BLAT("Finished checking that compare file exists.")
            BLAT("About to get bSizeMatch.\n")

            bool bSizeMatch = (Current->second.size == Compare->second.size);

            BLAT("\nIn EradicateDuplicates(), got bSizeMatch.")
            BLAT("bSizeMatch = " << std::boolalpha << bSizeMatch)
            BLAT("About to skip to next Compare file if bSizeMatch is false.\n")

            // If sizes don't match, continue to next "Compare" file:
            if (!bSizeMatch)
            {
               BLAT("\nIn EradicateDuplicates(); bSizeMatch is false.\n")
               continue;
            }

            // Otherwise, don't skip to next "Compare" file:
            else
            {
               BLAT("\nIn EradicateDuplicates(); bSizeMatch is true.\n")
               ; // do nothing
            }

            BLAT("\nIn EradicateDuplicates(), about to get bIdentical.\n")

            bool bIdentical = rhdir::FilesAreIdentical(Current->second.name, Compare->second.name);

            BLAT("\nIn EradicateDuplicates(), got bIdentical.")
            BLAT("bIdentical = " << std::boolalpha << bIdentical)
            BLAT("About to skip to next Compare file if bIdentical is false.\n")

            // If files aren't identical, continue to next "Compare" file:
            if (!bIdentical)
            {
               BLAT("\nIn EradicateDuplicates(); bIdentical is false.\n")
               continue;
            }

            else
            {
               BLAT("\nIn EradicateDuplicates(); bIdentical is true.\n")
               ;
            }

            // If we get to here, Current and Compare files are the same size and compare identical.

            BLAT("\nIn EradicateDuplicates(); about to erase a file; but which one?\n")


            // We're about to delete a file, so increment deletion counter:
            Stats.IncDelCount();

            // Find out which file is newer, and store iterators to the newer and older
            // files in "NewerFile" and "OlderFile":
            if (Current->second.timestamp > Compare->second.timestamp)
            {
               OlderFile = Compare;
               NewerFile = Current;
            }
            else
            {
               OlderFile = Current;
               NewerFile = Compare;
            }

            // If in Erase-Older-File Mode, erase older file instead of newer:
            if (Bools.bOlder)
            {

               BLAT("\nIn EradicateDuplicates(); in Erase-Older-File mode; about to erase older file.\n")

               // If not being quiet, announce deletion of older file:
               if (!Bools.bQuiet)
               {
                  cout
                     << endl
                     << "Duplicate deletion #" << Stats.GetDelCount() << ":" << endl
                     << OlderFile->second.name << endl
                     << "is a duplicate of" << endl
                     << NewerFile->second.name << endl
                     << "In Erase-Older-File Mode, so about to erase older file:" << endl
                     << "Erasing " << OlderFile->second.name << endl;
               }

               // Erase older file from hard disk:
               remove(OlderFile->second.name.c_str());

               // And also erase older file from multimap:
               M.erase(OlderFile);
            }

            // Otherwise, delete the newer of the two files:
            else
            {

               BLAT("\nIn EradicateDuplicates(); Erase-Newer-File Mode; about to erase newer file.\n")

               // If not being quiet, announce deletion of newer file:
               if (!Bools.bQuiet)
               {
                  cout
                     << endl
                     << "Duplicate deletion #" << Stats.GetDelCount() << ":" << endl
                     << NewerFile->second.name << endl
                     << "is a duplicate of" << endl
                     << OlderFile->second.name << endl
                     << "In Erase-Newer-File Mode, so about to erase newer file:" << endl
                     << "Erasing " << NewerFile->second.name << endl;
               }

               // Erase newer file from hard disk:
               remove(NewerFile->second.name.c_str());

               // And also erase newer file from multimap:
               M.erase(NewerFile);
            }

            // Set flag to indicate we've erased a file:
            bErasedFile = true;

            BLAT("\nIn EradicateDuplicates(), at bottom of innermost for loop.")
            BLAT("Finished erasing file.  About to break from loop.\n")

            // Break from this inner "for" loop:
            break;

         } // end for (each Compare file)

         // If we erased a file in the inner "for" loop, break from outer "for" loop as well:
         if (bErasedFile)
         {
            BLAT("\nIn EradicateDuplicates(), at bottom of outer for loop.")
            BLAT("We just erased a file, so about to break.\n")
            break;
         }

         // Otherwise, don't break:
         else
         {
            BLAT("\nIn EradicateDuplicates(), at bottom of outer for loop.")
            BLAT("We didn't erase a file, so we don't break.\n")
            ; // Do nothing.
         }

      } // end for (each Current file)

      #ifdef BLAT_ENABLE
      if (bErasedFile)
      {
         BLAT("\nIn EradicateDuplicates(), at bottom of do loop.")
         BLAT("We erased a file, so we loop again.\n")
      }
      else
      {
         BLAT("\nIn EradicateDuplicates(), at bottom of do loop.")
         BLAT("We didn't erase a file, so we stop looping now.\n")
      }
      #endif

   } while (bErasedFile);

   BLAT("\nAt end of EradicateDuplicates(), about to return 0.\n")

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
   BLAT("\nJust entered IsPathological(), about to get StrippedName.\n")

   std::string StrippedName = rhdir::Denumerate(Name);

   BLAT("\nIn IsPathological(), got StrippedName.")
   BLAT("StrippedName = " << StrippedName)
   BLAT("About to get Prefix and Suffix.\n")

   std::string Prefix = rhdir::GetPrefix(StrippedName);
   std::string Suffix = rhdir::GetSuffix(StrippedName);

   BLAT("\nIn IsPathological(), got Prefix and Suffix.")
   BLAT("Prefix = " << Prefix)
   BLAT("Suffix = " << Suffix)
   BLAT("About to run final if/else.\n")

   if (Prefix.empty())
   {
      BLAT("\nIn IsPathological().")
      BLAT("Prefix is empty.")
      BLAT("About to return true.\n")
      return true;
   }
   else if (Suffix.empty())
   {
      BLAT("\nIn IsPathological().")
      BLAT("Suffix is empty.")
      BLAT("About to return true.\n")
      return true;
   }
   else
   {
      BLAT("\nIn IsPathological().")
      BLAT("Neither Prefix nor Suffix is empty.")
      BLAT("About to return false.\n")
      return false;
   }
} // end ns_DedupNewsbin::IsPathological()



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
   BLAT("\nJust entered IsCandidate(), about to call IsPathological().\n")

   // If name is pathological, file is not a candidate:
   bool bPatho = IsPathological(Name);

   BLAT("\nIn IsCandidate(), just returned from IsPathological().")
   BLAT("Name   = " << Name)
   BLAT("bPatho = " << bPatho << "\n")

   if (bPatho)
   {
      BLAT("\nIn IsCandidate() if(bPatho).")
      BLAT("About to return false because file name is pathological.\n")
      return false;
   }
   else
   {
      BLAT("\nIn IsCandidate() else(!bPatho).")
      BLAT("NOT about to return false, because file name is NOT pathological.\n")
      ; // do nothing
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
         BLAT("\nIn IsCandidate().")
         BLAT("About to return true because file name contains an enumerator.")
         BLAT("File name = " << Name << "\n")
         return true;
      }
   }

   BLAT("\nAt bottom of IsCandidate().")
   BLAT("About to return false because file name does not contain an enumerator.")
   BLAT("File name = " << Name << "\n")
   return false;
} // end ns_DedupNewsbin::IsCandidate()


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
   << "Command-line syntax:"                                                             << endl
                                                                                         << endl
   << "dedup-newsbin-files [switches and/or arguments, in any order]"                    << endl
                                                                                         << endl
   << "Valid switches and arguments include:"                                            << endl
                                                                                         << endl
   << "If a -r or --recurse switch is used, all of the subdirectories of the current"    << endl
   << "directory will also be processed."                                                << endl
                                                                                         << endl
   << "If a -q or --quiet switch is used, the program will become very un-verbose."      << endl
   << "All of the directory  and name-group announcements will be skipped, and the"      << endl
   << "only thing printed will be the final statistics."                                 << endl
                                                                                         << endl
   << "If a -h or --help switch is used, the application will just print these"          << endl
   << "instructions and exit.  (This over-rides all other flags.)"                       << endl
                                                                                         << endl
   << "If a -o or --older switch is used, older duplicates will be erased instead of"    << endl
   << "newer duplicates."                                                                << endl
                                                                                         << endl
   << "If one or more drive letters are used as arguments, all directories in all"       << endl
   << "given drives will be processed.  (This over-rides -r or --recurse.)"              << endl
   << "The drive letters must be upper-case, and separated by spaces."                   << endl
                                                                                         << endl
   << "Note on recursive or multi-drive processing:"                                     << endl
                                                                                         << endl
   << "This program (dedup-newsbin-FILES) does NOT do cross-directory or cross-drive"    << endl
   << "duplicate checking.  Files are compared to their directory-mates only."           << endl
   << "For cross-directory or cross-drive duplicate checking, use this program's"        << endl
   << "sister program, dedup-newsbin-MULTI, instead."                                    << endl;
   return;
} // end ns_DedupNewsbin::Help()
