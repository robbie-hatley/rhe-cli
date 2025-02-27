/****************************************************************************\
 * File name:   spellchk.cpp                                                *
 * Title:       Spell Checker                                               *
 * Authorship:  Written Monday April 28, 2003 by Robbie Hatley              *
 *              Last edited Wednesday May 21, 2003.                         *
 * Description: Checks spelling in ASCII text files.                        *
 * To use:      Invoke like this:                                           *
 *              spellchk filename.txt                                       *
 *              Spell Checker will then prompt you regarding each word in   *
 *              filename.txt which it cannot find in its dictionaries,      *
 *              giving you the choice of correcting the word, or adding it  *
 *              to personal.dic, or ignoring it.                            *
 * To make:     Link with modules "rhutil.o" and "rhdir.o" in "librh.a".    *
\****************************************************************************/

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cctype>

#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>
#include <vector>
#include <list>
#include <string>
#include <algorithm>
#include <functional>

// Define "BLAT_ENABLE" here so that BLAT is enabled in
// my personal library headers:
#define BLAT_ENABLE
#undef  BLAT_ENABLE

// Include personal library headers:
#include "rhutil.hpp"
#include "rhdir.hpp"

typedef  std::string::size_type                  SSSS;
typedef  std::list<std::string>                  LS;
typedef  std::list<std::string>::iterator        LSI;
typedef  std::list<std::string>::const_iterator  LSCI;

namespace ns_Spell
{
   using std::cin;
   using std::cout;
   using std::cerr;
   using std::endl;

   void
   SpellCheck
      (
         std::vector<std::string> const & Args
      );

   void
   BuildDictionary
      (
         std::list<std::string> & Dictionary
      );

   void
   GetText
      (
         std::vector<std::string> const & Args,
         std::list<std::string> & Text
      );

   void
   GetNextWord
      (
         std::string const & Line,
         std::string       & Word,
         SSSS              & WordPos,
         SSSS              & WordLen
      );

   bool
   IsInDict
      (
         std::string const & Word,
         LS          const & Dictionary
      );

   void
   CorrectWord
      (
         std::string       & Line,
         std::string const & Word,
         SSSS        const & WordPos,
         SSSS        const & WordLen
      );


   void
   Help
      (
         void
      );
}


int
main
   (
      int    Beren,
      char*  Luthien[]
   )
{
   using namespace ns_Spell;

   //rhdir::AppendFileToListFunctor.ref_count = 0;

   // Print help and exit if user uses help switch:
   if (rhutil::HelpDecider(Beren, Luthien, Help)) return 777;

   // Get arguments:
   std::vector<std::string> Args;
   rhutil::GetArguments(Beren, Luthien, Args);

   // Open an input stream, spell-check the input, and write spell-checked
   // version of input to output:
   try
   {
      SpellCheck(Args);
   }
   catch (rhdir::FileIOException E)
   {
      cerr << E.msg << endl;
      return 1; // Return failure code to OS.
   }

   // Return success code to OS:
   return 0;
} // end main()


// Spell-check input, and write spell-checked version of input to output:
void
ns_Spell::
SpellCheck
   (
      std::vector<std::string> const & Args // WAS: std::istream & inputStream
   )
{
   // Build dictionary:
   std::list<std::string> Dictionary;
   ns_Spell::BuildDictionary(Dictionary);

   // Read input file into list of strings:
   std::list<std::string> Text;
   ns_Spell::GetText(Args, Text);

   // Start reading lines; parse lines into words.
   // If words are found which are not in dictionaries, ask user to select
   // "ignore", "add to dictionary", or "change".
   // If "add", correct dict.
   // If "change", correct string in vector.
   // If "ignore", just move on.

   // Declare variables for spell checking:
   std::string   Word        = std::string("");
   SSSS          WordPos     = SSSS(0);
   SSSS          WordLen     = SSSS(0);
   LSI           i;

   // Process all lines of text in input file:
   for ( i = Text.begin() ; i != Text.end() ; ++i )
   {
      // Get reference to current line of text:
      std::string & Line = (*i);

      // Zero-out WordPos and WordLen, so that GetNextWord will get first word of line:
      WordPos = 0;
      WordLen = 0;

      // Get first word of line:
      GetNextWord(Line, Word, WordPos, WordLen);

      // For each word in line:
      while (std::string::npos != WordPos)
      {
         BLAT(endl)
         BLAT("In SpellCheck().  Just entered inner while loop.")
         BLAT("   Word     = " << Word)
         BLAT("   WordPos  = " << WordPos)
         BLAT("   WordLen  = " << WordLen)
         if (!IsInDict(Word, Dictionary))
         {
            CorrectWord(Line, Word, WordPos, WordLen);
         }

         // Get next word of line (if there is one):
         GetNextWord(Line, Word, WordPos, WordLen);
      }
   }
   return;
} // end SpellCheck()


// Build "Dictionary" from dictionary files:
void
ns_Spell::
BuildDictionary
   (
      std::list<std::string> & Dictionary
   )
{
   std::list<std::string> Dicts;
   rhdir::LoadFileList
   (
      Dicts,           // List of dictionary paths.
      "C:/bin/*.dic",  // Wildcard.
      1,               // Files only (no dirs).
      2                // Append to list without clearing.
   );

   // Define "Append" to mean "class rhdir::AppendFileToListFunctor",
   // for purposes of brevity:
   typedef class rhdir::AppendFileToListFunctor Append;

   // For each dictionary file, append its contents to Dictionary:
   Append
      FuncObj
      (
         for_each
         (
            Dicts.begin(),
            Dicts.end(),
            Append(Dictionary)
         )
      );

   // Convert all words in dictionary to all-lower-case:
   for_each(Dictionary.begin(), Dictionary.end(), rhutil::StringToLower_Functor());

   BLAT(std::endl)
   BLAT("In ns_Spell::BuildDictionary().")
   BLAT("   Number of files processed = " << FuncObj.applications)
   BLAT("   Size of Dictionary:       = " << Dictionary.size())

   rhutil::SortDup(Dictionary);

   rhdir::SaveContainerToFile(Dictionary, "C:/bin/dic.dic");

   return;
} // end BuildDictionary()



// Get text:
void
ns_Spell::
GetText
   (
      std::vector<std::string>  const  &  Args,  // Arguments of main().
      std::list<std::string>           &  Text   // Text to be spell-checked.
   )
{
   // If there's at least one argument,
   //    if first arg a valid file path,
   //       then use it as our input file,
   //    else,
   //       print error message and bail,
   // else,
   //    use cin as input.
   if (Args.size() > 0)
   {
      if (rhdir::FileExists(Args[0]))
      {
         rhdir::LoadFileToContainer(Args[0], Text);
      }
      else
      {
         rhdir::FileIOException up
            ("Error in ns_Spell::SpellCheck(): Invalid input file path.");
         throw up;
      }
   }

   // Otherwise, read input from keyboard:
   else
   {
      std::string LineOfText;

      while (1)
      {
         std::getline(cin, LineOfText);

         // If stream is bad, throw up:
         if (StreamIsBad(cin))
         {
            rhdir::FileIOException up
            (
               "Error in ns_Spell::SpellCheck(): Bad IO stream while reading text from keyboard."
            );
            throw up;
         }

         // If end of file, break out of while loop:
         if (cin.eof())
         {
            break;
         }

         // Otherwise, append LineOfText to end of Text:
         Text.push_back(LineOfText);
      } // end while (1)
   } // end else (no arguments)

   return;
} // end GetText()


void
ns_Spell::
GetNextWord
   (
      std::string const & Line,
      std::string       & Word,
      SSSS              & WordPos,
      SSSS              & WordLen
   )
{
   SSSS Start      = 0;
   SSSS NextDelim  = 0;

   Start = WordPos + WordLen;

   if (Start >= Line.size())
   {
      WordPos = std::string::npos;
      goto exit_point;
   }

   WordPos = Line.find_first_of("abcdefghijklmnopqrstuvwxyzABCEDFGHIJKLMNOPQRSTUVWXYZ", Start);

   if (std::string::npos == WordPos)
   {
      goto exit_point;
   }

   NextDelim = Line.find_first_of(" ,.?\";:~!@#$%^&*+=()[]{}<>\\|/", WordPos);

   WordLen = (std::string::npos == NextDelim) ? (Line.size() - WordPos) : (NextDelim - WordPos);

   Word = Line.substr(WordPos, WordLen);

   exit_point:
   ;

   BLAT(endl)
   BLAT("About to return from GetNextWord.")
   BLAT("   Start    = " << Start)
   BLAT("   WordPos  = " << WordPos)
   BLAT("   WordLen  = " << WordLen)
   BLAT("   Word     = " << Word)

   return;
} // end GetNextWord()


bool
ns_Spell::
IsInDict
   (
      std::string const & Word,
      LS          const & Dictionary
   )
{
   return
   (
      Dictionary.end() !=
         find
         (
            Dictionary.begin(),
            Dictionary.end(),
            rhutil::StringToLower(Word)
         )
   );
} // end IsInDict()


void
ns_Spell::
CorrectWord
   (
      std::string       & Line,
      std::string const & Word,
      SSSS        const & WordPos,
      SSSS        const & WordLen
   )
{
   cout << "Word \"" << Word << "\" isn't in dictionary." << endl;
   return;
} // end CorrectWord()


void
ns_Spell::
Help
   (
      void
   )
{
   //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
   cout
   << "Welcome to Robbie Hatley's Nifty Spelling Checker."                                     << endl
                                                                                               << endl
   << "This version compiled at " << __TIME__ << " on " << __DATE__ << "."                     << endl
                                                                                               << endl
   << "Command-line syntax:"                                                                   << endl
   << "spellchk [switches] [argument] [< InputFile] [> OutputFile]"                            << endl
                                                                                               << endl
   << "Switch:                          Meaning:"                                              << endl
   << "\"-h\" or \"--help\"             Print help and exit."                                  << endl
   << "No other switches are recognized."                                                      << endl
                                                                                               << endl
   << "If no argument, input file, or output file are given, input is from stdin and"          << endl
   << "output is to stdout.  Input and output can be redirected with '<' and '>'."             << endl
   << "If an argument is given, it is interpreted as a file path, and that file (if it"        << endl
   << "exists) is used for input.  If the argument is not a valid path to a file, an"          << endl
   << "error message is displayed.  Any arguments after the first one are ignored."            << endl
                                                                                               << endl
   << "My spelling checker uses all files with extention \"dic\" which it finds in"            << endl
   << "the \"C:\\bin\" directory as its dictionary, so put whatever dictionary file(s)"        << endl
   << "you want to use in your \"C:\\bin\" directory, change their extentions to \"dic\","     << endl
   << "and make sure they consist of ASCII or ISO-8858-1 text files with one word per"         << endl
   << "line, sorted, with no punctuation, no leading whitespace, no trailing whitespace,"      << endl
   << "and no duplicates."                                                                     << endl
                                                                                               << endl
   << "Spell Checker will prompt you regarding each word of its input which it cannot"         << endl
   << "find in its dictionaries, giving you the choice of correcting the word, adding"         << endl
   << "the word to dictionary \"spellchk-custom.dic\", or ignoring the word.  Each line"       << endl
   << "of the input is written to the output after each word on the current line is"           << endl
   << "spell-checked (and possibly corrected)."                                                << endl
                                                                                               << endl
   << "WARNING: As with all such utilities, it is not advisible to use the input file"         << endl
   << "as the output file.  That might work, or it might not.  At best, it increases"          << endl
   << "danger of the input file being corrupted.  At worst, it may wipe-out the input"         << endl
   << "file, or wipe-out other files, or crash or even damage your system.  It's"              << endl
   << "always safer to use separate file names for input and output."                          << endl;

   return;
} // end Help()


