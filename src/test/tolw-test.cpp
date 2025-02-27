#include <cctype>
#include <iostream>
#include <string>
#include <algorithm>
using namespace std;
int main (void) {
  string str("TExt to Change tO lowEr CASe");
  transform(str.begin(), str.end(), str.begin(), ::tolower);
  cout << str << endl;
  return 0;
}
