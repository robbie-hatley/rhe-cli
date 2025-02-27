#include <iostream>
#include <string>

using namespace std;

extern void WeirdFunction (void);

int main (void)
{
   double Frank;
   cout << "Enter a number. (Enter 0 to quit.)" << endl;
   cin >> Frank;
   if (Frank > -0.000001 && Frank < +0.000001)
      goto SAYONARA;
   cout << Frank << endl;
   WeirdFunction();
   SAYONARA:
   return 0;
}