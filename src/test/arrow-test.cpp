// arrow-test.cpp
#include <iostream>
struct Fred
{
   int value;
};
Fred asdf;
Fred* m (void)
{
   return &asdf;
}
int main (void)
{
   asdf.value = 7;
   std::cout << m()->value << std::endl;
   return 0;
}