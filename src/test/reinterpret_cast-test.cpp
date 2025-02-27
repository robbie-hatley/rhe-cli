
// reinterpret_cast-test.cpp

#include <iostream>
#include <string>
#include <utility>
#include <map>
#include <initializer_list>

typedef std::map<std::string,std::string> SSM;

using std::cout;
using std::endl;
using std::string;
using std::pair;

void print(const SSM& dict);

int main (void)
{
   int         Fred      = -587;
   unsigned    Bob       = 0;
   double      Sam       = 0;
   int        *Tom       = 0;

   cout << "Fred = " << Fred << endl;

   Bob = static_cast<unsigned>(Fred);           // OKAY
   cout 
      << "static_cast<unsigned>(Fred) = " 
      << Bob 
      << endl;

   // Bob = reinterpret_cast<unsigned>(Fred);      // ERROR
   // cout 
   //    << "reinterpret_cast<unsigned>(Fred) = " 
   //    << Bob 
   //    << endl;

   Sam = static_cast<double>(Fred);             // OKAY
   cout 
      << "static_cast<double>(Fred) = " 
      << Sam 
      << endl;

   // Sam = reinterpret_cast<double>(Fred);        // ERROR
   // cout 
   //    << "reinterpret_cast<double>(Fred) = " 
   //    << Sam 
   //    << endl;

   // Tom = static_cast<int*>(Fred);               // ERROR
   // cout 
   //    << "static_cast<int*>(Fred) = " 
   //    << Tom 
   //    << endl;

   Tom = reinterpret_cast<int*>(Fred);          // OKAY
   cout 
      << "reinterpret_cast<int*>(Fred) = " 
      << Tom 
      << endl;

   SSM MyMap (pair<string,string>("alpha","dog"), pair<string,string>("beta","cat"));
   //MyMap["alpha"] = "dog";
   //MyMap["beta"]  = "cat";

   print(MyMap);

   return 0;

} // end main()


void print(const SSM& dict) {
  for(SSM::const_iterator p=dict.begin(); p!=dict.end(); ++p) {
    std::cout << p->first << " -> " << p->second << std::endl;
  }
}


// end file template.cpp
