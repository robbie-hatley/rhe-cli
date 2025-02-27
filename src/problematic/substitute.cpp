
/************************************************************************************************************\
 * Program name:  Substitute
 * File name:     substitute.cpp
 * Source for:    substitute.exe
 * Description:   Does a s/// style substitution on stdin, writing substituted version to stdout.
 * Author:        Robbie Hatley
 * Date written:  Tue Mar 31, 2015
 * Inputs:        command-line arguments and stdin
 * Outputs:       stdout
 * Notes:         I'm electing to use stdin & stdout instead of files so that this can be used with | < > .
 * To make:       Link with objects rhutil.o and rhregex.o in library "librh.a" in directory "/rhe/lib".
 * Edit History:
 *   Tue Mar 31, 2015 - Wrote the first draft.
\************************************************************************************************************/

#include <iostream>
#include <vector>
#include <string>

// Use assert?  (Undefine "NDEBUG" to use asserts; define it to NOT use them.)
#define NDEBUG
//#undef  NDEBUG
//#include <assert.h>
//d#include <errno.h>

// Use BLAT?  (Define "BLAT_ENABLE" to use BLAT; undefine it to NOT use BLAT.)
#define BLAT_ENABLE
#undef  BLAT_ENABLE

// Include personal library headers:
#include "rhutil.hpp"
#include "rhregex.hpp"

namespace ns_Substitute
{
   using std::cin;
   using std::cout;
   using std::cerr;
   using std::endl;
   using std::flush;

   typedef  std::vector<std::string>   VS;
   typedef  VS::iterator               VSI;
   typedef  VS::const_iterator         VSCI;

   struct Settings_t  // Program settings (boolean or otherwise).
   {
      bool bHelp; // Did user ask for help?
   };

   void
   ProcessFlags       // Set settings based on flags.
   (
      VS          const  &  Flags,
      Settings_t         &  Settings
   );

   int 
   CheckArguments    // Checks arguments for validity.
   (
      VS          const  &  Arguments
   );

   void 
   Substitute
   (
      VS          const  &  Arguments
   );

   void Help (void);

} // end namespace ns_Substitute


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  main()                                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

int main (int Beren, char * Luthien[])
{
   using namespace ns_Substitute;

   Settings_t Settings = Settings_t();

   // Get & process flags:
   VS Flags;
   rhutil::GetFlags (Beren, Luthien, Flags);
   ProcessFlags(Flags, Settings);

   // If user wants help, just print help and return:
   if (Settings.bHelp)
   {
      Help();
      return 777;
   }

   // Otherwise, get & check arguments:
   VS Arguments;
   rhutil::GetArguments(Beren, Luthien, Arguments);
   int Result = CheckArguments(Arguments);
   if (42 != Result) return 666;

   // Do the substitutions and print the results:
   Substitute(Arguments);

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
ns_Substitute::
ProcessFlags
   (
      VS          const  &  Flags,
      Settings_t         &  Settings
   )
{
   BLAT("\nJust entered ProcessFlags().  About to set settings.\n")

   // Use InVec from rhutil:
   using rhutil::InVec;

   Settings.bHelp = InVec(Flags, "-h") or InVec(Flags, "--help"   );

   BLAT("About to return from ProcessFlags.\n")
   return;
} // end ns_Substitute::ProcessFlags()



//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  CheckArguments()                                                        //
//                                                                          //
//  Checks validity of arguments.                                           //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

int 
ns_Substitute::
CheckArguments
   (
      VS          const  &  Arguments
   )
{
   BLAT("\nJust entered CheckArguments().\n")

   if (!(2 == Arguments.size() || 3 == Arguments.size()))
   {
      cerr 
         << "Invalid number of arguments."                                    << endl
         << "Substitute takes 2 or 3 arguments:"                              << endl
         << "RegEx pattern to search for"                                     << endl
         << "Replacement string"                                              << endl
         << "(optional) Flag character (defaults to g for global)"            << endl
                                                                              << endl
         << "Text to be searched is input is via stdin, pipe, or redirect."   << endl
         << "Output is via stdout."                                           << endl;
      return 666;
   }

   BLAT("About to return from CheckArguments.\n")
   return 42;
} // end ns_Substitute::CheckArguments()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Substitute()                                                            //
//                                                                          //
//  Substitutes a replacement string for matches to a RegEx in some text.   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void 
ns_Substitute::
Substitute
   (
      VS          const  &  Arguments
   )
{
   std::string  Pattern      =  Arguments[0];
   std::string  Replacement  =  Arguments[1];
   char Flag = 
      (3 == Arguments.size() && 'g' == Arguments[2][0]) 
      ? 'g'
      : 'n';
   std::string  LineIn       = "";
   std::string  LineOut      = "";

   while (std::getline(cin,LineIn))
   {
      LineOut = rhregex::Substitute(Pattern, Replacement, LineIn, Flag);
      cout << LineOut << endl;
   }
   return;
}



//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Help()                                                                  //
//                                                                          //
//  Prints help.                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_Substitute::
Help
   (
      void
   )
{
   //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
   cout
                                                                                               << endl
   << "Welcome to Substitute, Robbie Hatley's nifty text substitution utility."                << endl
   << "This program searches for a given RegEx pattern in text, and substitutes"               << endl
   << "a given replacement string for each matching substring, similar to"                     << endl
   << "the s/// operator from Sed, Awk, and Perl."                                             << endl
                                                                                               << endl
   << "This version compiled at " << __TIME__ << " on " << __DATE__ << "."                     << endl
                                                                                               << endl
   << "Command-line syntax:"                                                                   << endl
   << "substitute [switches] [arguments] < InputFile > OutputFile"                             << endl
                                                                                               << endl
   << "Switch:                      Meaning:"                                                  << endl
   << "\"-h\" or \"--help\"             Print help and exit."                                  << endl
                                                                                               << endl
   << "Substitute takes 2 or 3 arguments:"                                                     << endl
   << "Arg1: RegEx pattern to search for"                                                      << endl
   << "Arg2: Replacement string (may contain backreferences)"                                  << endl
   << "Arg3 (optional): \'g\' for \"global\"."                                                 << endl
   << "If Arg3 is given and if Arg3 starts with the letter \'g\', then"                        << endl
   << "a \"global\" replace is done. Otherwise, \"global\" is turned off."                     << endl
   << "The text to be searched is input via stdin, redirect, or pipe."                         << endl
   << "The substituted text is output via stdout, redirect, or pipe."                          << endl
                                                                                               << endl;
   return;
} // end ns_Substitute::Help()
