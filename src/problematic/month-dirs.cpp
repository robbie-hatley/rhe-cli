/************************************************************************************************************\
 * Program name:  Month Dirs
 * File name:     month-dirs.cpp
 * Source for:    month-dirs.exe
 * Author:        Robbie Hatley.
 * Date written:  Fri Feb 05, 2010.
 * Inputs:        If a "-h" or "--help" flag is present, prints help and exits.
 * Outputs:       Creates directories 01-12 in current directory.
 * Edit history:
 *    Fri Feb 05, 2010 - Wrote it, based on "Day Dirs".
\************************************************************************************************************/

#include <iostream>
#include <string>
#include <sys/stat.h>

#include "rhutil.hpp"
#include "rhdir.hpp"

using std::cout;
using std::endl;

void MonthDirs (void);
void Help      (void);

int main (int Elbereth, char* Gilthoniel[])
{
   if (rhutil::HelpDecider(Elbereth, Gilthoniel, Help)) goto End;
   MonthDirs();
   End: return 0;
}

void MonthDirs (void)
{
   // make 01-12 directories:
   char Path    [3] = "--"         ;  Path    [2] = '\0';
   char Digits [11] = "0123456789" ;  Digits [10] = '\0';
   int  Num         = 0            ;
   for(short int i=0; i<10; ++i)
   {
      for (short int j=0; j<10; ++j)
      {
         Path[0] = Digits[i];
         Path[1] = Digits[j];
         Num = 10*i+j;
         if (Num <  1) continue;
         if (Num > 12) break;
         mkdir(Path, 0); // Read-only.  (To disable, use S_IWUSR instead of 0.)
      }
   }
   return;
}

void Help (void)
{
   cout
                                                                                        << endl
   << "Welcome to Month Dirs, Robbie Hatley's 01-12 directory-set creator."             << endl
                                                                                        << endl
   << "This version was compiled at " << __TIME__ << " on "<< __DATE__ << "."           << endl
                                                                                        << endl
   << "Month Dirs creates 12 empty subdirectories in the current directory,"            << endl
   << "named \"01\" through \"12\".  This is especially useful for sorting files by"    << endl
   << "date, using nested year/month/day folders."                                      << endl
                                                                                        << endl
   << "Month Dirs ignores any arguments except for the -h or --help switches,"          << endl
   << "which will cause NumDirs to print these instuctions then exit."                  << endl
                                                                                        << endl;
   return;
}
