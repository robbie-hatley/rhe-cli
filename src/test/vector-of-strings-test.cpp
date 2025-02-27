// vector-of-strings-test.cpp
#include <iostream>
#include <vector>
#include <string>
using namespace std;
int main (void)
{
   vector<string> MyStrings;
   MyStrings.push_back("Apple");
   MyStrings.push_back("Pear");
   MyStrings.push_back("Orange");
   for (string s : MyStrings)
   {
      cout << s << endl;
   }
   return 0;
}