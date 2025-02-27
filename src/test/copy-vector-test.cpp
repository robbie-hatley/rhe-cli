// copy-vector-test.cpp
#include <vector>
#include <iostream>
using namespace std;
int main (void)
{
   vector<int> Sam = {1,2,3};
   vector<int> Bob = Sam; // Bob is copy of Sam.
   for ( auto x : Bob )
      cout << x << endl;
   return 0;
}