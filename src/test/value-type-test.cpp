#include <iostream>
template<typename T>
class MyClass
{
   public:
      typedef T value_type;
      MyClass(T a) : a_(a) {}
      T get_a() {return a_;}
   private:
      T a_;
};

int main()
{
   MyClass<int>::value_type Object = 7;
   MyClass<int> Widget (Object);
   std::cout << Widget.get_a() << std::endl;
   return 0;
}
