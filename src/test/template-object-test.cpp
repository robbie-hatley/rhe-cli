#include <iostream>
#include <vector>
using namespace std;
int main (void)
{
   // make object of template class:
   std::vector<int> Fred = {1,2,3,4,5};
   // print contents of object:
   for ( int i = 0 ; i < 5 ; ++i )
   {
      cout << Fred[i] << endl;
   }
}