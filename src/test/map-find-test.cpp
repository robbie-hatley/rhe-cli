#include <map>
#include <iostream>
#include <string>

using namespace std;

int main()
{
   map<string , string > p;
   string s1("George");
   string s2("W");
   string s3("Bush");
   string s4("Bin");
   string s5("Laden");
   p[s1] = s2;
   p[s3] = s4;
   
   if (p.find(s5) != p.end())
   {
      cout <<" found !\n ";
   }
   
   else
   {
      cout << "Not found !\n";
   }
   
   return 0 ;
}
