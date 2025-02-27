// quadratic.cpp
// A test of functors and function objects

#include <iostream>

using namespace std;

class Quadratic
{
  public:
    Quadratic(double aa, double bb, double cc) : a(aa), b(bb), c(cc) {}
    double operator()(double x) {return a*x*x+b*x+c;}
  private:
    double a;
    double b;
    double c;
};

int main(int argc, char**argv)
{
  double a,b,c,x,y;
  a=atof(argv[1]); b=atof(argv[2]); c=atof(argv[3]);
  Quadratic quad (a,b,c);
  cout << "x?  ";
  cin >> x;
  y=quad(x);
  cout << endl << "a*x*x + b*x + c = " << y << endl;
  return 0;
}
