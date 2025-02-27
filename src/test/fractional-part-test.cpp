// fractional-part-test.cpp
#include <iostream>
#include <iomanip>
using namespace std;
int main (void)
{
   double number;
   cout << "Type a number, then hit Enter." << endl;
   cin >> number;
   double integ_part;
   double fract_part;

   // Student calculates integral and fractional parts of
   // the number "number" here. Put some effort into it!
   // Read your textboook! Consult your class notes!
   // Flex your brain! Experiment! Don't be afraid to 
   // make mistakes! That's just part of programming!

   cout << setprecision(15);
   cout << "Number you typed: " << number     << endl;
   cout << "Integer Part:     " << integ_part << endl;
   cout << "Fractional Part:  " << fract_part << endl;
   
   return 0;
}
