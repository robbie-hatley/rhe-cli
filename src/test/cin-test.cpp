#include <iostream>
#include <string>

using namespace std;

int main()
{
   string   s;
   int      i;
   float    f;
   
   cout 
      << "Key-in a string, space, integer, space, float, then hit Enter." 
      << endl;

   cin >> s >> i >> f;

   cout
      << "You entered the string  " << s << endl
      << "You entered the integer " << i << endl
      << "You entered the float   " << f << endl;

   return 0;
}
