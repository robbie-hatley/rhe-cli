// push-back-test.cpp
#include <iostream>
#include <string>
#include <vector>
int main (void)
{
   std::vector<std::string> animals;
   animals.reserve(100);
   animals.push_back("pig");
   animals.push_back("chicken");
   animals.push_back("dog");
   animals.push_back("wolf");
   animals.push_back("cow");
   animals.push_back("horse");
   for(auto x : animals)
      std::cout << x << std::endl;
   return 0;
}