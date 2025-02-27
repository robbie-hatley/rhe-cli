#include <iostream>
#include <iomanip>
#include <string>
#include <sstream>

#include <regex>

int main (void)
{
   std::regex  RE   {"ai"};
   std::string Fred {"Cain slew Abel"}; 
   std::cout << regex_match  (Fred, RE) << std::endl;
   std::cout << regex_search (Fred, RE) << std::endl;
   return 0;
}
