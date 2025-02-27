// vec-char-test.cpp
#include <iostream>
#include <vector>
using std::vector, std::cout, std::endl;
int main()
{
   vector<char> u, l;
   // Load vectors:
   for (char c = 65; c <=  89; ++c) u.push_back(c);
   for (char c = 97; c <= 121; ++c) l.push_back(c);
   // Print vectors:
   for (char c : u) {cout << c;} cout << endl;
   for (char c : l) {cout << c;} cout << endl;
   return 0;
}