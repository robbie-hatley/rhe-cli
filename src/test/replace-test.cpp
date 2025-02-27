#include <iostream>
#include <string>
int main (void)
{
   std::string S ("hello");
   S.replace(S.find("ll"), 2, "abc");
   std::cout << S << std::endl;
   return 0;
}
