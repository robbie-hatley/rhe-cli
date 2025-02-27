// average-no-array-test.cpp
#include<iostream>
using namespace std;
int main (void)
{
   double Number      = 0.0;
   double Accumulator = 0.0;
   int    Count       = 0;
   cout << "Enter some numbers, pressing Enter after each number," << endl;
   cout << "then enter 0 and press Enter to end data entry:"       << endl;
   while (1)
   {
      cin >> Number;
      if (Number < 0.000001) // floating-point is not exact!!!!!
         break;
      Accumulator += Number;
      ++Count;
   }
   cout << "Average = " << Accumulator/Count << endl;
   return 0;
}
