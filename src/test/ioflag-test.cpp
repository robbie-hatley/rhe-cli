/****************************************************************************\
 * ioflagtest.cpp
 *
 *
 *
 *
 *
 *
\****************************************************************************/

using namespace std;

#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <cstring>
#include <cctype>
#include <cmath>
#include <ctime>
#include <new>
#include <typeinfo>

template<typename T>
void Binary(T const & object)
{
  size_t size = 8 * sizeof(object); // Size of object in bits.
  unsigned long long int mask = 
     static_cast<unsigned long long int>
        (pow(2.0, static_cast<double>(size - 1)) + 0.1);
  unsigned long long int pattern = 
     *reinterpret_cast<const unsigned long long int*>(&object);
  for( ; mask > 0 ; mask >>= 1)
  {
    if(pattern & mask) cout << "1";
    else cout << "0";
  }
  cout << endl;
  return;
}

int main()
{
  float  asdf = 32.45;
  cout << "typeid(asdf).name() = " << typeid(asdf).name() << endl;
  Binary(asdf);
  double qwer = 32.45;
  cout << "typeid(qwer).name() = " << typeid(qwer).name() << endl;
  Binary(qwer);
  cout << hex;
  cout << "boolalpha=   " <<ios::boolalpha    <<endl;
  cout << "dec=         " <<ios::dec          <<endl;
  cout << "oct=         " <<ios::oct          <<endl;
  cout << "hex=         " <<ios::hex          <<endl;
  cout << "adjustfield= " <<ios::adjustfield  <<endl;
  cout << "basefield=   " <<ios::basefield    <<endl;
  cout << "uppercase=   " <<ios::uppercase    <<endl;
  return 0;
}

