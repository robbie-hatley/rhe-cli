// array-of-strings-test.cpp
#include <cstdio>
using namespace std;
int main (void)
{
   char Fruits[3][10] = {"apple", "orange", "pair"};
   for ( int i = 0 ; i < 3 ; ++i )
      printf("Fruits[%1d] = %s\n", i, Fruits[i]);
   return 0;
}
