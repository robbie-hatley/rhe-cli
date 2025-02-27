#include <iostream>
#include <string>

#include "rhdir.hpp"

int main(void)
{
   std::string Text = std::string("AB37XY92BJ");
   std::cout << rhdir::Number(Text) << std::endl;
   return 0;
}

