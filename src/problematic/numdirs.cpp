/************************************************************************************************************\
 * File name:     numdirs.cpp
 * Title:         Numeric Directory Creator, 0-9
 * Author:        Robbie Hatley.
 * Date Written:  Tue Dec 02, 2003.
 * Inputs:        If a "-h" or "--help" flag is present, prints help and exits.
 * Outputs:       Creates directories 0-9 in current directory.
 * Edit history:
 *    Tue Dec 02, 2003 - Wrote it.
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

void NumDirs  (void);
void Help     (void);

int main (int Elbereth, char* Gilthoniel[])
{
   if (rhutil::HelpDecider(Elbereth, Gilthoniel, Help)) return 777;
   NumDirs();
   return 0;
}

void NumDirs (void)
{
   // make 0-9 directories:
   char Path    [2] = "-"          ;  Path    [1] = '\0';
   char Digits [11] = "0123456789" ;  Digits [10] = '\0';
   for(short int i=0; i<10; ++i)
   {
      Path[0] = Digits[i];
      mkdir(Path, 0); // Read-only.  (To disable, use S_IWUSR instead of 0.)
   }
   return;
}

void Help (void)
{
   cout
   << "Welcome to NumDirs, Robbie Hatley's 0-9 directory-set creation utility."         << endl
                                                                                        << endl
   << "This version was compiled at " << __TIME__ << " on "<< __DATE__ << "."           << endl
                                                                                        << endl
   << "NumDirs creates 10 empty subdirectories in the current directory, named"         << endl
   << "\"0\" through \"9\"."                                                            << endl
                                                                                        << endl
   << "NumDirs ignores any arguments except for the -h or --help switches, which will"  << endl
   << "cause NumDirs to print these instuctions then exit."                             << endl;
   return;
}
