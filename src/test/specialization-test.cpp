#include <iostream>
#include <iomanip>

using std::cout;
using std::endl;

struct DoubleTrouble
{
   long double a;
   double getDouble() const {return static_cast<double>(a);}
};

template <class numericType>
double getAverage(const numericType& a, const numericType& b)
{
   return double(a + b) / 2.0;
}

template<>
double getAverage(const DoubleTrouble& a, const DoubleTrouble& b)
{
   return (a.getDouble() + b.getDouble()) / 2.0;
}

int main()
{
   DoubleTrouble Blat;
   Blat.a  = 396739.39548;
   DoubleTrouble Splat;
   Splat.a = 833902.39583;
   cout
      << std::setprecision(15) 
      << "Blat.a  = " << Blat.a                  << endl
      << "Splat.a = " << Splat.a                 << endl
      << "Average = " << getAverage(Blat, Splat) << endl;
   return 0;
}
