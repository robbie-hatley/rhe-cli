
/****************************************************************************\
 * File name:   boxify.cpp                                                  *
 * Title:       Boxify                                                      *
 * Authorship:  Written Fri. July 12, 2002, by Robbie Hatley.               *
 *              Last updated Mon. July 15, 2002.                            *
 * Description: Draws comment boxes around C++ comments in a C/C++ source   *
 *              code file.                                                  *
 * Inputs:      One command-line argument giving name of file to be         *
 *              boxified.                                                   *
 * Outputs:     file with same name but extention "box"                     *
 * Notes:       useful for C/C++ programming                                *
\****************************************************************************/

#include <ctime>

#include <iostream>
#include <iomanip>

#include "rhutil.hpp"
#include "rhdir.hpp"

using std::cin;
using std::cout;
using std::endl;

namespace ns_Boxify
{
   using std::cout;
   using std::cerr;
   using std::endl;
   using std::setfill;
   using std::setw;

   typedef  std::vector<std::string>  VS;
   typedef  VS::iterator              VSI;
   typedef  VS::const_iterator        VSCI;

   struct Bools_t     // program boolean settings
   {
      bool bHelp;     // Did user ask for help?

   };

   void
   ProcessFlags
   (
      VS           const  &  Flags,
      Bools_t             &  Bools
   );

   void Boxify (void);

   void Help (void);

}


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  main()                                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

int main(int Beren, char * Luthien[])
{
   using namespace ns_Boxify;
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

   Boxify();

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
ns_Boxify::
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

   BLAT("About to return from ProcessFlags.\n")
   return;
} // end ns_Boxify::ProcessFlags()


void ns_Boxify::Boxify (void)
{
   cout
      << "Note RH 2009-03-29: This program is now an extreme stubb."       << endl
      << "I #if 0'ed out most of the contents, because it was implimented" << endl
      << "far too dangerously.  It needs to be re-written so that it uses" << endl
      << "cin and cout for all its input and output instead of altering"   << endl
      << "the original input file.  It also needs to make much more use"   << endl
      << "of the C++ std lib and much less use of the C std lib."          << endl
      << "For now, it just prints this paragraph and exits."               << endl;
   return;
}


#if 0


void Parse(char *OrigFileName) {

  // Declare constants:
  const char mark1[3]={'/', '*', '\0'}; // open-comment mark
  const char mark2[3]={'*', '/', '\0'}; // close-comment mark

  // Declare streams:
  ifstream i_stream;        // input  file stream
  ofstream o_stream;        // output file stream

  // Declare & initialize local variables:
  unsigned short int i=0; // counter for "for" loops
  int line_num=0;                  // line number
  bool error_flag=false;           // error flag
  bool comment_flag=false;         // comment flag

  // Declare & initialize line buffer character array:
  char buf[253]={'\0'};

  // Open file in input mode for parsing:
  i_stream.open(OrigFileName);
  if (!i_stream) {
    cerr << "Error: cannot open file in input mode for parsing." << endl;
    exit(1);
  }

  // Parse file:
  while (true) {

    ++line_num;

    // wipe old trash from line buffer:
    for (i=0; i<253;  ++i) buf[i]='\0';

    // Get line of text from file and put in buffer:
    i_stream.getline(buf, 250);

    if (i_stream.bad()) {
      cerr << "Fatal error occurred while attempting to read line "
           << line_num
           << " from original file during parsing."
           << endl;
      exit(1);
    }

    if (i_stream.eof()) {
      break;
    }

    if (i_stream.fail()) {
      cerr << "Non-fatal error while attempting to read line "
           << line_num
           << " from original file during parsing."
           << endl;
      i_stream.clear();
    }

    // Parse open-comment marks:
    if (NULL!=strstr(buf, mark1)) { // if open-comment mark found:
      if (0!=strcmp(buf, mark1)) { // if mark not alone on line:
        cout << "Line "
             << line_num
             << " has mis-placed open-comment mark."
             << endl;
        error_flag=true;
      }
      else { // if mark is alone on line:
        if (comment_flag) { // if in comment mode:
          cout << "Line "
               << line_num
               << " has mis-matched open-comment mark."
               << endl;
          error_flag=true;
        }
        else { // if not in comment mode:
          comment_flag=true; // enter comment mode
        }
      }
    }

    // Parse close-comment marks:
    if (NULL!=strstr(buf, mark2)) { // if close-comment mark found:
      if (0!=strcmp(buf, mark2)) { // if mark not alone on line:
        cout << "Line "
             << line_num
             << " has mis-placed close-comment mark."
             << endl;
        error_flag=true;
      }
      else { // if mark is alone on line:
        if (!comment_flag) { // if not in comment mode:
          cout << "Line "
               << line_num
               << " has mis-matched close-comment mark."
               << endl;
          error_flag=true;
        }
        else { // if in comment mode:
          comment_flag=false; // exit comment mode
        }
      }
    }

    // Check line length of lines to be included in comment boxes:
    if (comment_flag && strlen(buf)>72) {
      cout << "Line "
           << line_num
           << " is part of a comment and is over 72 characters long."
           << endl;
      error_flag=true;
    }

  } // Exit "while" loop.  Finished parsing file.

  // Close file:
  i_stream.close();

  // Bail out if commenting errors were encountered in file:
  if (error_flag) {
    cout << "Cannot boxify file because errors were encountered (see details "
         << "above).  Fix the errors in the source code and try again."
         << endl;
    exit(1);
  }

  // Otherwise, announce successful parsing of file:
  cout << OrigFileName << " has been successfully parsed." << endl;
  return;
}

void Backup(char *OrigFileName, char *BackupFileName) {

  // Declare streams:
  ifstream i_stream;        // input  file stream
  ofstream o_stream;        // output file stream

  // Declare and initialize local variables:
  unsigned short int i=0; // counter for "for" loops
  int line_num=0;                  // line counter

  // Declare & initialize line buffer character array:
  char buf[253]={'\0'};

  i_stream.open(OrigFileName);
  if (!i_stream) {
    cerr << "Error: cannot open "
         << OrigFileName
         << "in input mode for backup."
         << endl;
    exit(1);
  }

  o_stream.open(BackupFileName);
  if (!o_stream) {
    cerr << "Error: cannot open "
         << BackupFileName
         << "in output mode for backup."
         << endl;
    exit(1);
  }

  while (true) {

    ++line_num;

    // wipe old trash from line buffer:
    for (i=0; i<253;  ++i) buf[i]='\0';

    // Get line of text from input file and put in buffer:
    i_stream.getline(buf, 250);

    // Exit if fatal read error has occurred:
    if (i_stream.bad()) {
      cerr << "Fatal error while attempting to read line "
           << line_num
           << " from original file during backup.  Aborting backup "
           << "process.  Please erase corrupt backup file."
           << endl;
      exit(1);
    }

    // Break if end of input file has been reached:
    if (i_stream.eof()) {
      break;
    }

    // Print warning and continue if non-fatal read error has occurred:
    if (i_stream.fail()) {
      cerr << "Non-fatal error while attempting to read line "
           << line_num
           << " from original file during backup.  Backup file may be "
           << "corrupt."
           << endl;
      i_stream.clear();
    }

    // Write line of text from buffer to backup file:
    o_stream << buf << endl;

    // Exit if fatal write error has occurred:
    if (o_stream.bad()) {
      cerr << "Fatal error while attempting to write line "
           << line_num
           << " to backup file during backup.  Aborting backup "
           << "process.  Please erase corrupt backup file."
           << endl;
      exit(1);
    }

    // Print warning and continue if non-fatal write error has occurred:
    if (o_stream.fail()) {
      cerr << "Non-fatal error while attempting to write line "
           << line_num
           << " to backup file during backup.  Backup file may be "
           << "corrupt."
           << endl;
      o_stream.clear();
    }

    // Flush output stream:
    o_stream.flush();

  } // End "while" loop.

  // Flush output stream and close all open files:
  o_stream.flush();
  i_stream.close();
  o_stream.close();

  // Announce successful backup:
  cout << OrigFileName
       << " has been successfully backed up to "
       << BackupFileName
       << "."
       << endl;
  return;
}

void Boxify(char *BackupFileName, char *OrigFileName) {

  // Declare streams:
  ifstream i_stream;        // input  file stream
  ofstream o_stream;        // output file stream

  // Declare and initialize local variables:
  unsigned short int i=0; // counter for "for" loops
  int line_num=0;                  // line number
  bool comment_flag=false;         // comment flag

  // Declare & initialize line buffer character array:
  char buf[253]={'\0'};

  // Open backup file for input:
  i_stream.open(BackupFileName);
  if (!i_stream) {
    cerr << "Error: cannot open "
         << BackupFileName
         << "in input mode for boxification."
         << endl;
    exit(1);
  }

  // Open original file for output:
  o_stream.open(OrigFileName);
  if (!o_stream) {
    cerr << "Error: cannot open "
         << OrigFileName
         << "in output mode for boxification."
         << endl;
    exit(1);
  }

  // Boxify file:
  while (true) {

    ++line_num;

    // wipe old trash from line buffer:
    for (i=0; i<253;  ++i) buf[i]='\0';

    // Get line of text from backup file and put in line buffer:
    i_stream.getline(buf, 250);

    // Exit if fatal read error has occurred:
    if (i_stream.bad()) {
      cerr << "Fatal error while attempting to read line "
           << line_num
           << " from backup file during boxification.  Aborting "
           << "boxification process.  Original file is now corrupt; "
           << "please erase original file and replace with backup."
           << endl;
      exit(1);
    }

    // Break out of "while" loop when end of input file has been reached:
    if (i_stream.eof()) {
      break;
    }

    // Print warning and continue if non-fatal read error has occurred:
    if (i_stream.fail()) {
      cerr << "Non-fatal error while attempting to read line "
           << line_num
           << " from backup file during boxification.  Original file may be "
           << "corrupt."
           << endl;
      i_stream.clear();
    }

    if ('/'==buf[0] && '*'==buf[1]) {
      comment_flag=true;
      o_stream << '/'
               << "**************************************"
               << "**************************************"
               << '\\'
               << endl;
    }
    else if ('*'==buf[0] && '/'==buf[1]) {
      comment_flag=false;
      o_stream << '\\'
               << "**************************************"
               << "**************************************"
               << '/'
               << endl;
    }
    else if (comment_flag) {
      o_stream << " * " << buf;
      for (i=0; i<(72-strlen(buf)); ++i) o_stream << ' ';
      o_stream << " * " << endl;
    }
    else {
      o_stream << buf << endl;
    }

    // Exit if fatal write error has occurred:
    if (o_stream.bad()) {
      cerr << "Fatal error while attempting to write line "
           << line_num
           << " to original file during boxification.  Aborting "
           << "boxification process.  Original file is now corrupt.  Please "
           << "erase original file and replace with backup."
           << endl;
      exit(1);
    }

    // Print warning and continue if non-fatal write error has occurred:
    if (o_stream.fail()) {
      cerr << "Non-fatal error while attempting to write line "
           << line_num
           << " to original file during boxification.  Original file may be "
           << "corrupt."
           << endl;
      o_stream.clear();
    }
    o_stream.flush();
  } // Exit "while" loop.

  // Flush output stream and close all open files:
  o_stream.flush();
  i_stream.close();
  o_stream.close();

  // Announce successful boxification:
  cout << OrigFileName << " has been successfully boxified." << endl;
  return;
}

#endif

void ns_Boxify::Help(void)
{
   //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
   cout
   << "Welcome to Boxify, Robbie Hatley's C/C++ comment-boxing utility."                       << endl
                                                                                               << endl
   << "This version compiled at " << __TIME__ << " on " << __DATE__ << "."                     << endl
                                                                                               << endl
   << "Command-line syntax:"                                                                   << endl
                                                                                               << endl
   << "To print help and exit:"                                                                << endl
   << "boxify -h|--help"                                                                       << endl
                                                                                               << endl
   << "To boxify the comments in a source file:"                                               << endl
   << "boxify < InputFile > OutputFile"                                                        << endl
                                                                                               << endl
   << "All of boxify's input and output is via redirection using < and >."                     << endl
   << "Boxify never alters original files."                                                    << endl
                                                                                               << endl
   << "The file to be boxified should be a valid C or C++ source code file, in which"          << endl
   << "each " << '/' << '*' << " and " << '*' << '/' << " mark stands on it's own"             << endl
   << "line, with no leading or trailing spaces or other characters."                          << endl
   << "Boxify will then output a version of the file with neat boxes of asterisks"             << endl
   << "drawn around all the comments."                                                         << endl;
  return;
}
