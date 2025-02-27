// Qsort test program, 2003-8-9

#include <iostream>
#include <string>
#include <vector>
#include "rhDutchSort.hpp"

using std::cout;
using std::endl;
using std::vector;
using std::string;

void Display(double* d, int len);
void Display(string* d, int len);

int main(void)
{
  double Fred[30]=
  {
     1.3, 93.0, 45.9, 17.4, 89.0, 22.3, 44.2, 47.9,  2.0, 74.4,
    78.0, 79.2, 32.9, 31.8, 49.3, 42.5, 57.6, 59.5, 13.2, 82.4,
    85.1, 92.1, 37.5, 34.3, 31.6, 98.8, 50.2, 30.8, 20.7, 35.5
  };
  
  Display(Fred, 30);
  
  rhDutchSort::Qsort<double>(Fred, 30);
  
  Display(Fred, 30);
  
  string Sam[10];
  Sam[0]="Golf is my favorite sport.";
  Sam[1]="Zebras are dorky.";
  Sam[2]="Chevrolets are the best cars.";
  Sam[3]="Monkeys are arboreal.";
  Sam[4]="I've always hated Muzak.";
  Sam[5]="Quirky engineers rile stuffy managers.";
  Sam[6]="Once I owned a pet bear.";
  Sam[7]="Ninety-nine bottles of beer on the wall...";
  Sam[8]="Koreans like kim-chee.";
  Sam[9]="Operators can be unary or binary.";
  
  Display(Sam, 10);
  
  rhDutchSort::Qsort<string>(Sam, 10);
  
  Display(Sam, 10);

 
  
  return 0;
}

void Display(double* d, int len)
{
  cout << endl;
  for (int i=0; i<len; ++i)
  {
    cout << d[i] << ' ';
  }
  cout << endl << endl;
  return;
}

void Display(string* d, int len)
{
  cout << endl;
  for (int i=0; i<len; ++i)
  {
    cout << d[i] << endl;
  }
  cout << endl;
  return;
}

