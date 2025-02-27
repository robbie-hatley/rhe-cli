#include <iostream>
using namespace std;
namespace Alpha {int Fred;}
namespace Beta  {double Fred;}
int main (void)
{
   Alpha::Fred = 7;
   Beta::Fred = 3.2;
   cout << Alpha::Fred << "  " << Beta::Fred << endl;
   return 0;
}