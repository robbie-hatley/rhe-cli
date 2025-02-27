#include <iostream>
#include <vector>
using namespace std;
int main (void)
{
   vector<int> Fred = {37, 2946, -985, 127, -3}; // array
   vector<int>::iterator i; // iterator
   for ( i = Fred.begin() ; i < Fred.end() ; ++i )
   {
      cout << *i << endl;
   }
   return 0;
}
