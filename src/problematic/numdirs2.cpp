/************************************************************************************************************\
 * File name:     numdirs2.cpp
 * Title:         Numeric Directory Creator, 00-99
 * Author:        Robbie Hatley.
 * Date Written:  Tue Jun 07, 2005.
 * Inputs:        If a "-h" or "--help" flag is present, prints help and exits.
 * Outputs:       Creates directories 00-99 in current directory.
 * Edit history:
 *    Tue Jun 07, 2005 - Wrote it.
 *    Wed Aug 24, 2005 - Added help.
 *    Wed Sep 14, 2005 - Simplified, got rid of dependence on rhutil and rhdir.
\************************************************************************************************************/

#include <iostream>
#include <string>
#include <sys/stat.h>

#include "rhutil.hpp"
#include "rhdir.hpp"

using std::cout;
using std::endl;

void NumDirs2 (void);
void Help     (void);

int main (int Elbereth, char* Gilthoniel[])
{
   if (rhutil::HelpDecider(Elbereth, Gilthoniel, Help)) return 777;
   NumDirs2();
   return 0;
}

void NumDirs2 (void)
{
   // make 00-99 directories:
   char Path    [3] = "--"         ;  Path    [2] = '\0';
   char Digits [11] = "0123456789" ;  Digits [10] = '\0';
   for(short int i=0; i<10; ++i)
   {
      for (short int j=0; j<10; ++j)
      {
         Path[0] = Digits[i];
         Path[1] = Digits[j];
         mkdir(Path, 0); // Read-only.  (To disable, use S_IWUSR instead of 0.)
      }
   }
   return;
}

void Help (void)
{
   cout
   << "Welcome to NumDirs2, Robbie Hatley's 00-99 directory-set creation utility."      << endl
                                                                                        << endl
   << "This version was compiled at " << __TIME__ << " on "<< __DATE__ << "."           << endl
                                                                                        << endl
   << "NumDirs2 creates 100 empty subdirectories in the current directory, named"       << endl
   << "\"00\" through \"99\"."                                                          << endl
                                                                                        << endl
   << "NumDirs ignores any arguments except for the -h or --help switches, which will"  << endl
   << "cause NumDirs to print these instuctions then exit."                             << endl;
   return;
}
