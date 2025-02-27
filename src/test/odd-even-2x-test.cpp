// odd-even-2x-test.cpp (cpp ver of 2)
#include <iostream>
#include <cstdlib>
using namespace std;
int main (void)
{
   long Fred = 0;

   // Get an integer from user:
   cout << "Type an integer." << endl;
   cin  >> Fred;

   // If Fred modulo-2 is 1, Fred is odd:
   if ( 1 == Fred % 2 )
      cout << Fred << " is odd" << endl;

   // Otherwise, Fred is even:
   else
      cout << Fred << " is even" << endl;

   // We're done, so exit:
   exit(EXIT_SUCCESS);
}
