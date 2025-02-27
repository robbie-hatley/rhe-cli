#include <iostream>
#include <cmath>
using namespace std;
int main (int Beren, char * Luthien[])
{
   double A,B;
   if (3 != Beren) {cerr<<"needs 2 arguments"<<endl; return 666;}
   A = strtod(Luthien[1],NULL);
   B = strtod(Luthien[2],NULL);
   cout << sqrt(A*A + B*B) << endl;
   return 0;
}