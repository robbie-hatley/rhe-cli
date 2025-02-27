#include <iostream>
#include <list>

int main()
{
   // Make and load your list:
   std::list<char> List;
   for (char i = 0; i<8; ++i)
      List.push_back(i);
   
   // Get an iterator to fifth element:
   std::list<char>::iterator i;
   i = find(List.begin(), List.end(), 4);
   
   // Splice fifth-through-eighth elements to beginning:
   List.splice(List.begin(), List, i, List.end());
   
   // Print results and return:
   for (i = List.begin(); i != List.end(); ++i)
      std::cout << static_cast<int>(*i) << "  ";
   std::cout << std::endl;
   return 0;
}
