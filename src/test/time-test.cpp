#include <iostream>
#include <sstream>
#include <iomanip>
#include <string>
#include <ctime>

#include "rhutil.hpp"

using std::cin;
using std::cout;
using std::cerr;
using std::endl;
using std::setfill;
using std::setw;
using std::string;

int main (void)
{
   int          i           = 0;
   time_t       Time        = 0;
   std::string  MicroDate   = "";
   std::string  ShortDate   = "";
   std::string  LongDate    = "";
   std::string  TimeString0 = "";
   std::string  TimeString1 = "";

   Time = std::time(NULL);
   for ( i = 0 ; i < 50 ; ++i )
   {
      MicroDate   = rhutil::GetDate(Time, 0);
      ShortDate   = rhutil::GetDate(Time, 1);
      LongDate    = rhutil::GetDate(Time, 2);
      TimeString0 = rhutil::GetTime(Time, 0);
      TimeString1 = rhutil::GetTime(Time, 1);
      cout << "MicroDate   = " << MicroDate   << endl;
      cout << "ShortDate   = " << ShortDate   << endl;
      cout << "LongDate    = " << LongDate    << endl;
      cout << "TimeString0 = " << TimeString0 << endl;
      cout << "TimeString1 = " << TimeString1 << endl;
      Time += 3600;
      cout << endl;
   }
   return 0;
}
