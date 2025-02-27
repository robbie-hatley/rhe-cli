/************************************************************************************************************\
 * Program name:  Day-Of-Month-Dirs
 * File name:     day-of-month-dirs.cpp
 * Source for:    day-of-month-dirs.exe
 * Author:        Robbie Hatley.
 * Date written:  Sun Nov 15, 2009.
 * Inputs:        If a "-h" or "--help" flag is present, prints help and exits.
 * Outputs:       Creates directories 01-31 in current directory.
 * Edit history:
 *    Sun Nov 15, 2005 - Wrote it, based on "numdirs2.cpp".
\************************************************************************************************************/

#include <iostream>
#include <string>
#include <sys/stat.h>

#include "rhutil.hpp"
#include "rhdir.hpp"

using std::cout;
using std::endl;

void DayOfMonthDirs (void);
void Help           (void);

int main (int Elbereth, char* Gilthoniel[])
{
   if (rhutil::HelpDecider(Elbereth, Gilthoniel, Help)) goto End;
   DayOfMonthDirs();
   End: return 0;
}

void DayOfMonthDirs (void)
{
   // make 01-31 directories:
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
         if (Num > 31) break;
         mkdir(Path, 0); // Read-only.  (To disable, use S_IWUSR instead of 0.)
      }
   }
   return;
}

void Help (void)
{
   cout
                                                                                        << endl
   << "Welcome to Day-Of-Month-Dirs, Robbie Hatley's 01-31 directory-set creator."      << endl
                                                                                        << endl
   << "This version was compiled at " << __TIME__ << " on "<< __DATE__ << "."           << endl
                                                                                        << endl
   << "Day-Of-Month-Dirs creates 31 empty subdirectories in the current directory,"     << endl
   << "named \"01\" through \"31\".  This is especially useful for sorting files by"    << endl
   << "day-of-month, perhaps within nested year/month/day folders."                     << endl
                                                                                        << endl
   << "Day-Of-Month-Dirs ignores any arguments except for the -h or --help switches,"   << endl
   << "which will cause NumDirs to print these instuctions then exit."                  << endl
                                                                                        << endl;
   return;
}
