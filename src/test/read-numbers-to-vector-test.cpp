// read-numbers-to-vector-test.cpp
#include<iostream>
#include<vector>
using namespace std;
int main (void)
{
   size_t i;
   double Number;
   vector<double> Numbers;
   cout << "Enter some numbers, pressing Enter after each number," << endl;
   cout << "then enter 0 and press Enter to end data entry:" << endl;
   while (1)
   {
      cin >> Number;
      // Break if Number is near 0:
      if ( 0 == Number > -0.000001 && Number < 0.000001)
         break;
      Numbers.push_back(Number);
   }
   cout << "You entered these numbers:" << endl;
   for ( Number : Numbers )
   {
      cout << Number << endl;
   }
   return 0;
}
