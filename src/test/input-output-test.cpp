// input-output-test.cpp

#include <iostream>

using std::cout;
using std::cin;
using std::endl;

int main (void)
{
   char c = '\0';
   bool Repeat = true;
   while (Repeat)
   {
      cout
      << "Yes, programs have input and output, or they would not be" << endl
      << "able to take-in data or out-put data, and hence would be"  << endl
      << "useless. For example, THIS program is using the C++"       << endl
      << "\"iostream\" concept to output written data to"            << endl
      << "a display screen via \"cout\" and to accept input from"    << endl
      << "a keyboard via \"cin\"."                                   << endl
                                                                     << endl
      << "Would you like me to repeat that?"                         << endl
      << "Type y for yes or n for no, then press Enter."             << endl;
      cin >> c;
      Repeat = ('y' == c || 'Y' == c) ? true : false;
   }
   return 0;
}
