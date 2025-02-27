/****************************************************************************\
 * File name:   matrtest.cpp
 * Title:       Matrix Class Test Program
 * Authorship:  RH, 2002-12-21
 * Description: Tests Matrix class in mathutil library
 * Inputs:      
 * Outputs:     
 * Notes:       
 * To make: gxx -Wall -O2 matrtest.cpp ..\lib\mathutil.o -lm -o matrtest.exe
\****************************************************************************/

#include <cstdio>
#include <iostream>
#include <cstdlib>
#include <cstring>
#include <cmath>
#include <iomanip>
#include "..\lib\mathutil.hpp"

using namespace std;

int main(void)
{
  Matrix matrix1 (5, 5);
  int i;
  double x;
  for (i=1, x=1.0; i<=5; ++i, x+=1.0)
  {
    matrix1.set(i,i,x);
  }
  cout << "Determinant of 5x5 diagonal matrix = " << matrix1.det() << "." << endl;
  Matrix matrix2 (6, 6);
  for (i=1, x=1.0; i<=6; ++i, x+=1.0)
  {
    matrix2.set(i,7-i,x);
  }
  cout << "Determinant of 6x6 reverse diagonal matrix = " << matrix2.det() << "." << endl;
  Matrix matrix3 (3, 3);
  matrix3.set(1,1,3.28); matrix3.set(1,2,-4.14); matrix3.set(1,3,3.85);
  matrix3.set(2,1,5.41); matrix3.set(2,2,-2.94); matrix3.set(2,3,-2.53);
  matrix3.set(3,1,-4.53); matrix3.set(3,2,-4.18); matrix3.set(3,3,2.59);
  cout << "matrix 3 = " << endl;
  cout << "+3.28  -4.14  +3.85" << endl;
  cout << "+5.41  -2.94  -2.53" << endl;
  cout << "-4.53  -4.18  +2.59" << endl;
  cout << "Determinant of matrix3 = " << setprecision(10) << matrix3.det() << "." << endl;
  cout << "(Should be -187.44026)" << endl;
  return 0;
}
