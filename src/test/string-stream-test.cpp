#include <iostream>
#include <cstring>
#include <sstream>

using std::istringstream;
using std::cout;
using std::endl;

int main()
{
   typedef char CString[80];
   CString array1[5];
   CString string1 = "my red dog is handsome";
   std::istringstream blat(string1);
   char buffer[65];
   for (int i=0 ; i<5; ++i)
   {
      blat >> buffer;
      if (!blat) break;
      strcpy(array1[i], buffer);
   }
   for (int i=0 ; i<5; ++i)
   {
      cout << array1[i] << endl;
   }
   return 0;
}
