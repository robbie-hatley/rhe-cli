#include <iostream>

int main()
{
   using std::cout;
   using std::endl;
   int a[64];
   cout << "&a[0] = " << &a[0] << endl;
   cout << "a     = " << a     << endl;
   cout << "a+1   = " << a+1   << endl;
   return 0;
}
