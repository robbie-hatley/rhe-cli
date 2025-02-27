// class-demo-test.cpp

#include <iostream>

using namespace std;

// Make a class (a blueprint for creating objects):
class Parabola
{
   public:
      Parabola(double A, double B, double C)
         : a(A), b(B), c(C)
         {} // all the work is done by init list
      double operator() (double x)
      {
         return a*x*x + b*x + c;
      }
   private:
      double a;
      double b;
      double c;
};

int main (void)
{
   double x;

   // Make an object ("instance") of class Parabola;
   // in other words, "instantiate" class Parabola:

   Parabola MyParabola (2.1, -1.7, 3.6);

   // Note that "MyParabola" is now a SPECIFIC parabola,
   // NOT a general class.

   // Print some values of the parabola:
   for ( x = -10.0 ; x < 10.05 ; x+=0.1 )
   {
      cout << "f(" << x << ") = " << MyParabola(x) << endl;
   }

   return 0;
}
