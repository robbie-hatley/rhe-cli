// read-integers-to-vector-test.cpp
#include<iostream>
#include<vector>
int main (void)
{
   std::vector<int> Numbers;
   int Number;
   std::cout 
   << "Enter some integers,"       << std::endl
   << "pressing Enter after each," << std::endl
   << "with 0 as last integer"     << std::endl
   << "to indicate end of input:"  << std::endl;
   while (1)
   {
      std::cin >> Number;
      // Break if Number is near 0:
      if ( 0 == Number )
         break;
      Numbers.push_back(Number);
   }
   std::cout
   << "You entered these integers:" << std::endl;
   for ( auto x : Numbers )
      std::cout << x << std::endl;
   return 0;
}
