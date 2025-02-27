// empty-vector-test.cpp
#include <iostream>
#include <vector>
using namespace std;
int main (void)
{
   vector<int> Frank; // Creates empty ("null") vector. 
   Frank.push_back(5); // Frank now has 1 element. 
   Frank.push_back(1); // Frank now has 2 elements. 
   Frank.push_back(4); // Frank now has 3 elements.
   for (int num : Frank)
   {
      cout << num << endl;
   }
   return 0;
}