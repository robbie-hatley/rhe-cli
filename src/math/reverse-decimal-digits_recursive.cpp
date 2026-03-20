// reverse_recursive.cpp
#include <iostream>
#include <cstdlib>
#include <cstdint>
using namespace std;
uint64_t reverse (uint64_t fwd, uint64_t rev)
{
   if (0 == fwd)
      return rev;
   rev *= 10;
   rev += fwd%10;
   fwd /= 10;
   return (reverse(fwd, rev));
}
int main (int Beren, char *Luthien[])
{
   uint64_t number = 0;
   if (Beren >= 2)
      number = strtoul(Luthien[1], NULL, 10);
   cout << reverse(number, 0) << endl;
   return 0;
}
