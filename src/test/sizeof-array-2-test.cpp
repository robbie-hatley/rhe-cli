#include <iostream>
#define SIZE 1000000
int main (void)
{
   unsigned Num[SIZE];
   for (size_t i = 0; i < SIZE; ++i) {Num[i] = 200;}
   size_t Bytes = sizeof(Num);
   std::cout << "Num[] stores " << Bytes << " bytes of data.";
   return 0;
}
