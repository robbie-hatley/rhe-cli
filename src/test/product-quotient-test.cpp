#include <iostream>

using namespace std;

double x(double red)
{
   return (red*62.55/8.6);
}

double multiply(double a, double b)
{
   double e,f;
   e = x(a);
   f = x(b);
   return e * f;
}

double divide(double a, double b)
{
   double g,h;
   g = x(a);
   h = x(b);
   return g / h;
}

int main (void)
{
   double a;
   double b;
   cout << "enter first variable:  ";
   cin >> a;
   cout << "enter second variable: ";
   cin >> b;
   cout << multiply(a,b) << endl;
   cout << divide(a,b) << endl;
   return 0;
}
