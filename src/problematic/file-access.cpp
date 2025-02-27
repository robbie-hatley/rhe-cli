
/******************************************************************************\
 * Program name:  File Access
 * File name:     file-access.cpp
 * Source for:    file-access.exe
 * Description:   Displays the "access" info for a given file name: whether
 *                the file exists, is readable, is writable, is executable,
 *                is a directory.
 * Author:        Robbie Hatley
 * Date written:  Sat Mar 21, 2009
 * Inputs:        A file name, as a command-line arugment.
 * Outputs:       Prints file access info.
 * To make:       Link with "rhutil.o" and "rhdir.o" in "librh.a".
 * Edit History:
 *   Sat Mar 21, 2009 - Wrote it.
 *
\************************************************************************************************************/

#include <iostream>
#include <string>

#include <unistd.h>

// Use asserts?
#undef  NDEBUG
#define NDEBUG
#include <assert.h>
#include <errno.h>

// Use BLAT?
#define BLAT_ENABLE
#undef  BLAT_ENABLE

#include "rhutil.hpp"
#include "rhdir.hpp"

namespace ns_Access
{
   using std::cout;
   using std::cerr;
   using std::endl;

   void PrintFileInfo (std::string const & Name);
   void Help(void);

   unsigned long int DirCount;
}


int main ( int Beren , char *  Luthien [] )
{
   using namespace ns_Access;

   if (rhutil::HelpDecider(Beren, Luthien, Help)) return 777;

   if (2 != Beren)
   {
      cerr
         << "Error: file-access takes exactly 1 command-line argument,"      << endl
         << "which must be the name of the file you desire access info for." << endl;
      Help();
      return 666;
   }

   std::string Name = Luthien[1];

   PrintFileInfo(Name);

   return 0;
}


void ns_Access::PrintFileInfo (std::string const & Name)
{
   cout << "Exists?:       ";
   if (!access(Name.c_str(), F_OK))
   {
      cout << "YES" << endl;
   }
   else
   {
      cout << "NO"  << endl;
   }

   cout << "Readable?:     ";
   if (!access(Name.c_str(), R_OK))
   {
      cout << "YES" << endl;
   }
   else
   {
      cout << "NO"  << endl;
   }

   cout << "Writable?:     ";
   if (!access(Name.c_str(), W_OK))
   {
      cout << "YES" << endl;
   }
   else
   {
      cout << "NO"  << endl;
   }

   cout << "Executable?:   ";
   if (!access(Name.c_str(), X_OK))
   {
      cout << "YES" << endl;
   }
   else
   {
      cout << "NO"  << endl;
   }

   cout << "Is Directory?: ";
   if (!access(Name.c_str(), D_OK))
   {
      cout << "YES" << endl;
   }
   else
   {
      cout << "NO"  << endl;
   }

   return;
}


void ns_Access::Help (void)
{
   //  12345678901234567890123456789012345678901234567890123456789012345678901234567890
   cout
   << "Welcome to \"File Access\", Robbie Hatley's file-access-info utility."                  << endl
                                                                                               << endl
   << "This version compiled at " << __TIME__ << " on " << __DATE__ << "."                     << endl
                                                                                               << endl
   << "Command-line syntax:"                                                                   << endl
   << "file-access [switches] [arguments]"                                                     << endl
                                                                                               << endl
   << "Switch:                          Meaning:"                                              << endl
   << "\"-h\" or \"--help\"             Print help and exit."                                  << endl
                                                                                               << endl
   << "If a \"-h\" or \"--help\" switch is used, the program prints this help and exits."      << endl
   << "Otherwise, this program expects one command-line argument, which should be the"         << endl
   << "name of the file for which access info is desired.  This prgram will then print"        << endl
   << "the following information: whether the file exists, is readible, is writable,"          << endl
   << "is executable, is a directory."                                                         << endl;

   return;
}

// end file MyFancyProgram.cpp

