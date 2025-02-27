// append-first.cpp
#include <iostream>
#include <string>
#include <array>
#include <list>
int main (void)
{
   std::array<std::string,3>  Array  = {"apple", "banana", "cranberry"};
   std::list<std::string>     List   = {"cucumber", "potato", "lettuce"};

   List.push_back(Array.at(1));

   std::list<std::string>::iterator iter;
   for ( iter = List.begin() ; iter != List.end() ; ++iter )
   {
      std::cout << *iter << " ";
   }
   std::cout << std::endl;
   return 0;
}