#include <iostream>
#include <string>
#include <list>

using std::cout;
using std::endl;

int main()
{
   int* p = new int[10];
   cout << "int* p = new int[10];" << endl;
   cout << "sizeof( p) = " << sizeof( p) << endl;
   cout << "sizeof(*p) = " << sizeof(*p) << endl;
   return 0;
}
