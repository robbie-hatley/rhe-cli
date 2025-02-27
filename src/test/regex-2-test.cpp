#include <iostream>
#include <string>
#include "rhutil.hpp"

int main(int, char* Galadriel[])
{
   std::ios_base::sync_with_stdio();
   std::string Pattern     (Galadriel[1]);
   std::string Replacement (Galadriel[2]);
   std::string Text        (Galadriel[3]);
   std::cout << rhutil::Substitute(Pattern, Replacement, Text) << std::endl;
   return 0;
}
