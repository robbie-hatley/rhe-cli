// char-array-test.cpp

#include <iostream>

char Func(char* blat) 
{
   return *(blat+1);
}

int main(void)
{
   char a[80];
   a[0] = 'n';
   a[1] = 't';
   std::cout << "Func(&a[0]) = " << Func(&a[0]) << std::endl;
   return 0;
}
