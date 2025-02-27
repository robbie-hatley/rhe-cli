// weird2-test.cpp
#include <iostream>
#include <cmath>

double S(double x, double yin);
double pi(double xin, double yin)
{
  return (int(xin)-S(xin,yin)-1);
}

double min(double x, double y)
{
  return x>y?y:x;
}

double S(double x, double yin)
{
  double sum=0, i, sum1, sum2, dx=1;

  for ( i = 2 ; i <= yin ; i++ )
  {
    sum1 = ( pi(x/i,min(i-dx,sqrt(x/i))) - pi(i-dx,sqrt(i-dx))) ;
    sum2 = ( pi(i,sqrt(i)) - pi(i-dx,sqrt(i-dx)));
    sum+=(sum1 * sum2);
  }
  return sum;
}

int main()
{
  int input;
  std::cout << "Input positive integer" << std::endl;
  std::cin >> input;
  std::cout << pi(input,sqrt(input)) << std::endl;
  return 0;
}
