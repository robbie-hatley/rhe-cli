
// simplify-file-name-test.cpp

#include <iostream>
#include <string>

#include "rhdir.hpp"

int main (void)
{
   std::string Fred ("Dang, dratted dog %dE%f0%6F%aE%6e ate my zebra!");
   std::cout << rhdir::SimplifyFileName(Fred) << std::endl;
   return 0;
}
