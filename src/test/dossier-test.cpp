#include <iostream>
#include <string>
#include <sstream>

using std::cout;
using std::endl;

class Dossier
{
   public:
      // declare parameterized constructor here:
      Dossier(std::string InputString);
      // declare validation functions here
      // declare any other methods you need here
      std::string code;
      std::string number;
      std::string zip;
      std::string title;
      std::string first_name;
      std::string last_name;
      std::string dob;
};

Dossier::Dossier(std::string InputString)
{
   std::replace(InputString.begin(), InputString.end(), '\"', ' ');
   std::replace(InputString.begin(), InputString.end(), ',' , ' ');
   std::istringstream SS(InputString);
   SS >> code >> number >> zip >> title >> first_name >> last_name >> dob;
}
   
int main()
{
   std::string argle = "\"C1\",\"2\",\"12344\",\"Mr\",\"John\",\"Chan\",\"05/07/1976\"";
   Dossier d(argle);
   cout
      << d.code        << endl
      << d.number      << endl
      << d.zip         << endl
      << d.title       << endl
      << d.first_name  << endl
      << d.last_name   << endl
      << d.dob         << endl;
   return 0;
}
