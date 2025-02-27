// clock3.cpp
// Written by Robbie Hatley.
// Displays time and date.
// Last edited Saturday May 3, 2003.

#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <time.h>

using std::cout;
using std::endl;

std::string GetTimeString();

int main(void)
{
  cout << GetTimeString() << endl;
  return 0;
}

std::string GetTimeString()
{
  // Get calendar time:
  time_t caltime;   // variable to hold calendar time
  time(&caltime);   // Assign time to caltime using std. lib. "time" function.
   
  // Generate struct tm structured version of caltime:
  struct tm StructuredTime;               // variable to hold structured time
  StructuredTime = *localtime(&caltime);  // Load structure.
  
  // Make C-string and load with formatted time:
  static char FormattedTime[51];
  for (int i=0;i<51;++i) FormattedTime[i]='\0';
  strftime(FormattedTime, 50, "%I:%M%p, %A %B %d, %Y\n", &StructuredTime);
  
  // Convert to C++ style string and return this string:
  std::string Time = FormattedTime;
  return Time;
}

