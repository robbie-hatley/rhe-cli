
// index-out-of-range-test.cpp

#include <iostream>
#include <string>
#include <cctype>

int main (void)
{
   std::string Fred ("Dang, dratted dog ate my zebra!");
   std::cout << Fred.find('q', 107) << std::endl;
   std::cout << std::string::npos << std::endl;
   return 0;
}
