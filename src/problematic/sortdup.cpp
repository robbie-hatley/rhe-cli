/************************************************************************************************************\
 * File mame:       sortdup.cpp
 * Program name:    SortDup
 * Description:     Text File Sorting and DeDuping Program.
 * Author:          Robbie Hatley.
 * Date written:    Fri. May 09, 2003.
 * Notes:           This program reads lines of text from cin, and writes an ASCII-sorted, de-duped version
 *                  of its input to cout.  Input can be redirected by using "<" or "|".  Output can be
 *                  redirected by using ">" or "|".  This program is especially useful for building
 *                  alphabetized dictionaries of words, names, or phrases.
 * To make:         Link with object rhutil.o in librh.a.
 * Edit history:
 *    Wed Mar 10 2004 - Changed program so that it requires only one command-line argument, and it alters
 *                      its input file.  This is more dangerous, but much more convenient.  I also added
 *                      provision for writing a *.bak copy of the original input.
 *    Sun Dec 05 2004 - Fixed bug which caused help not to be displayed.
 *    Sat Jan 08 2005 - Fixed "doesn't check for pre-existance of back-up file" bug.
 *    Tue Jan 11 2005 - Converted back to separate input and output files.
 *                      Also, command-line switch "-h" now gives help.
 *    Fri Jan 14 2005 - Replace some lugubrious error-checking code blocks with assert() calls.
 *    Tue Feb 08 2005 - Fixed buggy help.
 *    Sat Mar 12 2005 - Changed input to cin and output to cout.  Input can be redirected by using "<"
 *                      or "|".  Output can be redirected by using ">" or "|".
 *    Fri May 27 2005 - Corrected comments.
 *    Sun Jun 19 2005 - Corrected "interprets redirects as arguments" bug.  (Just ignore all arguments.)
 *    Tue Jul 15 2008 - Improved help.
\************************************************************************************************************/

// Use asserts?
#undef NDEBUG
//#define NDEBUG
#include <assert.h>

#include <iostream>
#include <fstream>
#include <string>
#include <list>
#include <vector>

#include <cstdlib>
#include <cstring>
#include <ctime>

#define BLAT_ENABLE
#undef BLAT_ENABLE

#include "rhutil.hpp"
#include "rhdir.hpp"

namespace ns_RhSortDup
{
   using std::cin;
   using std::cout;
   using std::cerr;
   using std::endl;

   typedef  std::vector<std::string>  VS;

   struct Bools_t     // program boolean settings
   {
      bool bHelp;     // Did user ask for help?
      bool bNCS;      // Non-Case-Sensitive sort?
      bool bRC;       // Sort Thunderbird Usenet-Newsgroups RC file?
   };

   void
   ProcessFlags
   (
      VS           const  &  Flags,
      Bools_t             &  Bools
   );

   // Perform a up-to-colon case-insensitive compare of two std::strings:
   struct NoCaseColon
   {
     bool operator()(const std::string& a, const std::string& b) const
     {
       std::string::const_iterator i, j;
       for
          (

             i = a.begin(), j = b.begin()    // Start at beginning.

             ;

             i != a.end() &&  j != b.end()   // Continue while not at end
             && *i != ':' && *j != ':'       // and haven't reach a colon
             && tolower(*i) == tolower(*j)   // and current chars NCS equal.

             ;

             ++i, ++j                        // Increment string positions.

          )
       {
          ; // do nothing
       }
       if ( j == b.end() || ':' == *j ) { return false; }
       if ( i == a.end() || ':' == *i ) { return true;  }
       return (toupper(*i) < toupper(*j));
     }
   };

   void ReadInput(std::list<std::string>& Text);
   void WriteList(const std::list<std::string>& Text);
   void Help(void);
}


int main(int Thyme, char * Sage[])
{
   using namespace ns_RhSortDup;

   VS Flags;
   rhutil::GetFlags (Thyme, Sage, Flags);

   Bools_t Bools = Bools_t();
   ProcessFlags(Flags, Bools);

   if (Bools.bHelp)
   {
      Help();
      return 777;
   }

   // Make a list of strings to hold the text of the input:
   static std::list<std::string> Text;

   // Read input from cin to Text:
   ReadInput(Text);

   // Sort the list of strings:
   if (Bools.bRC)
   {
      Text.sort(NoCaseColon());
   }
   else
   {
      if (Bools.bNCS)
      {
         Text.sort(rhutil::NoCase());
      }
      else
      {
         Text.sort();
      }
   }

   // Remove duplicate lines from Text:
   Text.unique();

   // Write output from Text to cout:
   WriteList(Text);

   return 0;
}


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessFlags()                                                          //
//                                                                          //
//  Sets program-state booleans based on Flags.                             //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_RhSortDup::
ProcessFlags
   (
      VS       const  &  Flags,
      Bools_t         &  Bools
   )
{
   BLAT("\nJust entered ProcessFlags().  About to set Bools.\n")

   // Use InVec from rhutil:
   using rhutil::InVec;

   Bools.bHelp    = InVec(Flags, "-h") or InVec(Flags, "--help"              );
   Bools.bNCS     = InVec(Flags, "-n") or InVec(Flags, "--non-case-sensitive");
   Bools.bRC      = InVec(Flags, "-r") or InVec(Flags, "--rc"                );

   BLAT("About to return from ProcessFlags.\n")
   return;
} // end ns_MyNameSpace::ProcessFlags()


void ns_RhSortDup::ReadInput(std::list<std::string>& Text)
{
   std::string LineOfText;                   // Make a string to hold text.
   for (int i = 0; i < 10000000; ++i)        // Loop up to ten million times.
   {                                         // Top of loop.
      BLAT("At top of for loop; i = " << i)
      getline(cin, LineOfText);              // Get a line of text.
      if (cin.eof()) break;                  // Break if stream is end-of-file.
      if (cin.fail() or cin.bad())
      {
         cerr
            << "Error in program SortDup, in function ReadInput():" << endl
            << "Input stream cin is in failed or bad state."        << endl
            << "Terminating read sequence."                         << endl;
         break;
      }
      Text.push_back(LineOfText);            // Record data in list.
      BLAT("At bottom of for loop; i = " << i)
   }                                         // Do it again.
   return;                                   // We be done.
}


void ns_RhSortDup::WriteList(const std::list<std::string>& Text)
{
   for (std::list<std::string>::const_iterator i=Text.begin(); i!=Text.end(); ++i)
   {
      cout << (*i) << endl;
   }
   return;
}


void ns_RhSortDup::Help(void)
{
  cout
                                                                                         << endl
  << "Welcome to SortDup, Robbie Hatley's awesome sorter and duplicate line remover\n"   << endl
  << "for ASCII text files."                                                             << endl
                                                                                         << endl
  << "This version compiled at " << __TIME__ << " on " << __DATE__  << "."               << endl
                                                                                         << endl
  << "SortDup takes no command-line arguments.  Input is via stdin and output is via"    << endl
  << "stdout.  Input and output may be redirected from and to files by using < and >."   << endl
  << "Similarly, input and output may be redirected from and to programs by using |."    << endl
                                                                                         << endl
  << "The input lines are first sorted in ASCII order, then any duplicate lines are"     << endl
  << "removed.  The resulting text is then written to stdout."                           << endl
                                                                                         << endl
  << "SortDup can sort up to 10,000,000 lines of text.  Any text beyond that limit"      << endl
  << "will be truncated."                                                                << endl
                                                                                         << endl
  << "Switches:"                                                                         << endl
  << "If a -h or --help   switch is used, just prints this help and exits."              << endl
  << "If a -n or --nocase switch is used, sort will be non-case-sensitive."              << endl
  << "If a -r or --rc     switch is used, each string will be examined only up to,"      << endl
  << "but not including, the first colon.  This is perfect for sortduping Thunderbird"   << endl
  << "Usenet newsgroups-list RC files."                                                  << endl
                                                                                         << endl;
  return;
}
