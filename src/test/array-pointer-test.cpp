#include <iostream>

using std::cout;
using std::endl;

int main(void)
{
  int a[10];
  cout << "int a[10];"  << endl;
  cout << "  &a   :  " << (&a) << endl;
  cout << "   a   :  " << ( a) << endl;
  cout << "&a + 1 :  " << (&a + 1) << endl;
  cout << " a + 1 :  " << ( a + 1) << endl;
  return 0;
}
