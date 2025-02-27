
/************************************************************************************************************\
 * Program name:  For Each Dir
 * File name:     for-each-dir.cpp
 * Source for:    for-each-dir.exe
 * Description:   Executes a given command for each directory in tree.
 * Author:        Robbie Hatley
 * Date written:  Mon May 04, 2009
 * Inputs:        CL argument.  Interprets argument as command.
 * Outputs:       Executes command for each directory in tree.
 * To make:       Link with rhutil.o and rhdir.o in librh.a and 
 * Edit History:
 *   Mon May 04, 2009 - Wrote it, but it doesn't work worth shit.  Gives "bad command or file name" usually.
 *   2009, 2010, 2011 - Fucking thing still doesn't work.
 *   Mon Oct 15, 2012 - I finally got the goddam thing to work halfway decent, which required redirecting
 *                      user's command to "cmd /C ", which is invoked from "command.com", which is invoked
 *                      by system(), which is invoked by ProcessCurDirFunctor::operator().  "cmd.exe" is a 
 *                      32-bit program, whereas "command.com" is a legacy 16-bit program, so cmd is much more
 *                      flexible in the kinds of operations it can do.
\************************************************************************************************************/

#include <iostream>
#include <iomanip>
#include <vector>
#include <list>
#include <string>
#include <cstdlib>

// Use assert?  (Undefine "NDEBUG" to use asserts; define it to NOT use them.)
#define NDEBUG
#undef  NDEBUG
#include <assert.h>
#include <errno.h>

// Use BLAT?  (Define "BLAT_ENABLE" to use BLAT; undefine it to NOT use BLAT.)
#define BLAT_ENABLE
#undef  BLAT_ENABLE

// Include personal library headers:
#include "rhutil.hpp"
#include "rhdir.hpp"

namespace ns_fed
{
   using std::cin;
   using std::cout;
   using std::cerr;
   using std::endl;
   using std::setfill;
   using std::setw;

   typedef  std::list<std::string>     LS;
   typedef  LS::iterator               LSI;
   typedef  LS::const_iterator         LSCI;
   typedef  std::vector<std::string>   VS;
   typedef  VS::iterator               VSI;
   typedef  VS::const_iterator         VSCI;

   struct Settings_t  // Program settings (boolean or otherwise).
   {
      bool bHelp;     // Did user ask for help?
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
      void PrintStats (void);
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
               std::string  const &  SystemCommand_,
               Stats_t            &  Stats_
            )
            : SystemCommand(SystemCommand_), Stats(Stats_)
            {}
         void operator()(void); // defined below
      private:
         std::string  const &  SystemCommand;
         Stats_t            &  Stats;         // Non-const ref so () function can increment stats counters.
   };

   void Help (void);
}


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  main()                                                                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

int main (int Beren, char * Luthien[])
{
   using namespace ns_fed;

   //__system_flags = __system_allow_multiple_cmds || __system_allow_long_cmds || __system_call_cmdproc  || __system_use_shell;
   //system("set COMSPEC=C:\\WINNT\\SYSTEM32\\CMD.EXE");
   //system("set   SHELL=C:\\WINNT\\SYSTEM32\\CMD.EXE");

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

   if (1 != Arguments.size())
   {
      cerr
                                                                                              << endl
         << "Error: for-each.exe takes exactly 1 non-flag argument, which must be a valid  "  << endl
         << "CLI command no greater than 119 characters in length.  Instructions follow... "  << endl
                                                                                              << endl;
      Help();
      return 666;
   }

   if (Arguments[0].size() > 119)
   {
      cerr
                                                                                              << endl
         << "Error: command fed to for-each-dir.exe exceeds 119 characters in length. "       << endl
         << "Instructions follow... "                                                         << endl
                                                                                              << endl;
      Help();
      return 666;
   }

   // Build command string for system():
   std::string SystemCommand = std::string("cmd /C ") + std::string(Arguments[0]);

   // Make a stats object to hold program run-time statistics:
   Stats_t Stats = Stats_t();

   // Create a function object of type "ProcessCurDirFunctor" for use with CursDirs:
   ProcessCurDirFunctor ProcessCurDir (SystemCommand, Stats);

   // Recursively traverse directory tree from current directory, calling the ProcessCurDir function object
   // (which in turn invokes command.com (which in turn invokes cmd.exe (which in turn invokes the command
   // which the user sent to for-each-dir))) at each node, processing bottom nodes first and working up, 
   // processing starting directory last:
   rhdir::CursDirs(ProcessCurDir);

   // NOTE: The triple-nesting of commands above is necessary because DJGPP's "system()" function invokes
   // Windows XP's 16-bit command.com as it's command processor, but many commands can't be run from that,
   // so I tack-on "cmd /C " to the beginning of the user's command so as to invoke the command through
   // cmd.exe, which is invoked through command.com, which is invoked through system(), which is invoked
   // through for-each-dir.exe.  This is also why this program enforces a 119-character limit on commands:
   // because command.com has a 126-character limit, and I have to reserve 7 more characters for "cmd /C ".

   // Processing files is finished, so print final stats:
   Stats.PrintStats();

   // We be done, so scram:
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
ns_fed::
ProcessFlags
   (
      VS          const  &  Flags,
      Settings_t         &  Settings
   )
{
   BLAT("\nJust entered ProcessFlags().  About to set Settings.\n")

   // Use InVec from rhutil:
   using rhutil::InVec;

   Settings.bHelp = InVec(Flags, "-h") or InVec(Flags, "--help");

   BLAT("About to return from ProcessFlags.\n")
   return;
} // end ns_fed::ProcessFlags()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  ProcessCurDirFunctor::operator()                                        //
//                                                                          //
//  Processes current directory.                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void ns_fed::ProcessCurDirFunctor::operator() (void)
{
   BLAT("\nJust entered ProcessCurDir::operator().\n")

   // ABSTRACT:
   // This function interprets the first non-flag argument as a CLI command,
   // and executes that command for the current directory.  (And since this
   // function is called once for each directory in the current tree, the
   // command is executed once for each directory in the tree.)

   // Increment directory counter:
   ++Stats.DirCount;

   // Get current directory:
   std::string CurDir = rhdir::GetFullCurrPath();

   // Annouce processing current directory:
   cout
                                                                                << endl
      << "================================================================="    << endl
      << "Directory #" << Stats.DirCount << ": " << CurDir                      << endl
      << "Sending the following command to cmd.exe:"                            << endl
      << SystemCommand.substr(7)                                                << endl
                                                                                << endl;

   BLAT("\nSystemCommand = " << SystemCommand)
   BLAT("SystemCommand.size() = " << SystemCommand.size())
   BLAT("About to send SystemCommand to system.\n")

   system(SystemCommand.c_str());

   BLAT("\nAbout to return from ProcessCurDir::operator().\n")
   return;
} // end ns_fed::ProcessCurDirFunctor::operator()


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Stats_t::PrintStats()                                                   //
//                                                                          //
//  Prints program run-time statistics.                                     //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void ns_fed::Stats_t::PrintStats (void)
{
   cout
                                                                                << endl
      << "for-each-dir processed " << DirCount << " directories."               << endl
                                                                                << endl;
}


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Help()                                                                  //
//                                                                          //
//  Prints help.                                                            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

void
ns_fed::
Help
   (
      void
   )
{
   //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
   cout
   << "Welcome to \"For Each Dire\", by Robbie Hatley."                                        << endl
   << "This version compiled at " << __TIME__ << " on " << __DATE__ << "."                     << endl
                                                                                               << endl
                                                                                               << endl
   << "This program interprets its argument as a command.  It walks the current"               << endl
   << "directory tree, setting each directory in turn as \"current directory\","               << endl
   << "and executes the given command at each node of the tree."                               << endl
                                                                                               << endl
   << "Command-line syntax:"                                                                   << endl
                                                                                               << endl
   << "To print this help and exit:"                                                           << endl
   << "MyFancyProgram -h|--help"                                                               << endl
                                                                                               << endl
   << "To execute a command at each node of a directory tree:"                                 << endl
   << "MyFancyProgram command"                                                                 << endl
                                                                                               << endl
   << "IMPORTANT: If your command contains white-space characters, always enclose it"          << endl
   << "in \"double-quote marks\", else the white spaces will break it into multiple"           << endl
   << "arguments, generating an error message and causing the program to fail."                << endl;

   return;
} // end ns_fed::Help()

// end file MyFancyProgram.cpp
