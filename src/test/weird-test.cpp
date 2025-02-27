#include <iostream>
#include <cmath>

using namespace std;


double min(double, double);
double S(double, double);
double pi(double, double);


double min(double a, double b)
{
  return a>b?b:a;
}

double pi(double x, double y)
{
  return (x-S(x,y)-1);
}

double S(double x, double y)
{
  double sum=0, s1=0, s2=0;
  for(int i=2; i<=y; i++)
  {
    s1=(pi(x/i,min(i-1.0,sqrt(x/i)))-pi(i-1.0,sqrt(i-1.0)));
    s2=(pi(i,sqrt(double(i)))-pi(i-1.0,sqrt(i-1.0)));
    sum+=s1*s2;
  }
  return sum;
}

int main()
{
  int x;
  cout <<"Input positive integer"<<endl;
  cin>>x;
  cout << pi(double(x),sqrt(double(x))) << endl;
  return 0;
}
