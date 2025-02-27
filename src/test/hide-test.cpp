#include <iostream>

using std::cout; using std::endl;

class A {
   public:
   virtual void fun(int a) {
     cout << 2*a << endl;
   }
   virtual void fun(double b) {
     cout << 2.0*b << endl;
   }
};

class B : public A {
   public:
   void fun(int a) {
     cout << 5*a << endl;
   }
};

int main (void) {
  B bb;
  bb.A::fun(7.3);
  return 0;
}
