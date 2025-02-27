#include <iostream>
#include <string>
#include <list>

using std::cout;
using std::endl;

int main()
{
   std::list<std::string> Names;
   Names.push_back("Frederick Gotham");
   Names.push_back("Robbie Hatley");
   Names.push_back("Sabiyur");
   Names.push_back("Ian Collins");
   Names.push_back("Howard");
   Names.push_back("Goalie_Ca");
   cout << Names.size() << " people have responded to this thread" << endl;
   return 0;
}
