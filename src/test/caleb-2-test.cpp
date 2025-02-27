#include <iostream>
#include <cmath>

using namespace std;

//GLOBAL VARIABLES
double Y=0.0;
double M=0.0;
double D=0.0;

//FUNCTIONS:

double a(double y)
{
   return floor(y/100.0);
}

double LHS(double y, double m, double d)
{
   return floor(365.25*(y+4716.0)) + floor(30.6001*(m+1.0)) + 2.0 - a(y) + a(y)/4.0;
}

//CONVERSION FUNCTION
double GtJ(double y, double m, double d)
{
   if (m<=2)
   {
      m += 12;
      y -= 1;
   }
   return (LHS(y,m,d)) + d - 1524.5;
}

int main (void)
{
   cout<<"Day: ";
   cin>>D;
   cout<<"Month: ";
   cin>>M;
   cout<<"Year: ";
   cin>>Y;
   if (M<=2)
   {
      M+=12;
      Y-=1;
   }
   std::cout<<"Julian Date   (from cout)  : " <<std::fixed << LHS(Y,M,D) + D - 1524.5 <<endl; 
   std::cout<<"Julian Date (from function): " <<std::fixed << GtJ(Y,M,D)              <<endl;
   return 0;
}
