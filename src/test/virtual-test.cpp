#include <iostream>
using namespace std;

class baseClass {
  public:
    virtual void dothis();
};

class inheritedClass : public baseClass {
  public:
    virtual void dothis();
};
 
int main() {
  baseClass* theObject = new baseClass;
  theObject->dothis();
  baseClass *newObject=(baseClass *) new inheritedClass;
  newObject->dothis();
}
 
void baseClass::dothis() {
  cout<< "Base class function called.\n";
}
 
void inheritedClass::dothis()
{
  cout<< "Derived class function called.\n";
}
