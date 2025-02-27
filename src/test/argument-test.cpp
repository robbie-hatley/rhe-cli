#include <iostream>
#include <string>

using std::cout;
using std::endl;
using std::string;

int main(int argc, char* argv[])
{
   cout
      << "Argument count = " << argc << endl
      << "Arguments follow:" << endl;
   for (int i=0; i<argc; ++i)
   {
      cout << argv[i] << endl;
   }
   
   return 0;
}
