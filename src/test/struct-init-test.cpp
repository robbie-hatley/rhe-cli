#include <iostream>

struct MyStruct
{
   MyStruct () : asdf(0), qwer(0) {}
   int asdf;
   int qwer;
};

int main(void)
{
   MyStruct Blat;
   std::cout << Blat.asdf << std::endl;
   return 0;
}





