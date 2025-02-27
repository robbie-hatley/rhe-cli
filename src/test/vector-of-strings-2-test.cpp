// vector-of-strings-2-test.cpp
#include <iostream>
#include <string>
#include <vector>
using namespace std;
int main (void)
{
   vector<string> Fruits = {"apple", "orange", "pair"};
   for (string fruit : Fruits)
      cout << fruit << endl;
   return 0;
}
