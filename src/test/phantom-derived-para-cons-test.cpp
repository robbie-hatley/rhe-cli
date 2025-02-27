// phantom-derived-para-cons-test.cpp
#include <iostream>
class Base
{
   public:
      Base(int X, char C) : x(X), c(C) {}
   private:
      int  x;
      char c;
};
class Derived : public Base
{
   public:
      Derived(int X, char C) : Base(X, C) {}
   private:
};
int main (void)
{
   Derived Fred (37, 'f');
   std::cout << "om" << std::endl;
   return 0;
}

