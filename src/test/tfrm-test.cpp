#include <cctype>
#include <iostream>
#include <string>
#include <algorithm>
int main (void) {
  std::string str("TExt to Change tO lowEr CASe");
  std::transform(str.begin(), str.end(), str.begin(), tolower);
  std::cout << str << std::endl;
  return 0;
}

