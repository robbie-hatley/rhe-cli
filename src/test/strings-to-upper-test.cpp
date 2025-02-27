// strings-to-upper-test.cpp
#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
#include <cctype>
using namespace std;
int main (void)
{
   vector<string> OldVec = {"apple", "orange", "pear"};
   vector<string> NewVec;

   // Print old strings:
   cout << endl;
   cout << "Old strings:" << endl;
   for (string s : OldVec)
   {
      cout << s << endl;
   }

   // Make new strings:
   for (string s : OldVec)
   {
      string u;
      transform(s.begin(), s.end(), back_inserter(u), ::toupper);
      NewVec.push_back(u);
   }

   // Print new strings:
   cout << endl;
   cout << "New strings:" << endl;
   for (string s : NewVec)
   {
      cout << s << endl;
   }
   cout << endl;

   return 0;
}
