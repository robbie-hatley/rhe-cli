#include <iostream>
using namespace std;
long fac (long x)
{
   long f = 1;
   long i;
   for ( i = 2 ; i <= x ; ++i )
   {
      f *= i;
   }
   return f;
}
int main (int Beren, char * Luthien[])
{
   long x,y;
   if (2 != Beren) return 1;
   x = strtol(Luthien[1], NULL, 10);
   y = fac(x+3);
   cout << y << endl;
   return 0;
} // end main()
