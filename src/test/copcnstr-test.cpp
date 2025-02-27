#include <iostream>
#include <ctime>

using namespace std;

typedef unsigned int UInt32;

UInt32 getValue()
{
 return time(0);
}

class MyClass
{
public:
 MyClass() : mValue(0) {}
 MyClass(const UInt32 Value) : mValue(Value) {}
 UInt32 blat() const {return mValue;}

protected:
 MyClass(const MyClass & src) : mValue(src.mValue) {}
 MyClass& operator=(const MyClass & src)
 {
  if(this != &src)
   mValue = src.mValue;
  return *this;
 }

protected:
 UInt32 mValue;
};


int main()
{
  MyClass mcVar = getValue();
  cout << "mValue = " << mcVar.blat() << endl;
  return 0;
}

