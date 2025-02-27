#include <iostream>
#include <iomanip>
#include <cstdlib>

using std::cout;
using std::endl;
using std::setw;
using std::right;

int main(int argc, char *argv[])
{
   unsigned long int i=1, j=1, k=0, limit=atol(argv[1]);
   cout << setw(20) << right << i << endl;
   cout << setw(20) << right << j << endl;
   while (1)
   {
      k=i+j;
      if (k>limit) break;
      cout << setw(20) << right << k << endl;
      i=j;
      j=k;
   }
  return 0;
}
