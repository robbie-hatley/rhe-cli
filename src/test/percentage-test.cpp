#include <iostream>
using namespace std;
int main (int Beren, char * Luthien[])
{
   double a;
   double b;
   double p;
   // Bail if wrong # of args:
   if (3 != Beren)
      {cerr<<"missing args"<<endl;exit(666);}
   a = strtod(Luthien[1], NULL);
   b = strtod(Luthien[2], NULL);
   // Bail if b is close to 0:
   if (b>-0.00000001 && b<0.00000001)
      {cerr<<"division by zero"<<endl;exit(666);}
   p=100.0*a/b;
   cout << p << endl;
   return 0;
}
