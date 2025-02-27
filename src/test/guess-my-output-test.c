/*****************************************************************************\
 * Program name:  Guess My Output
 * File name:     guess-my-output.c
 * Description:   This program does something. What does it do?
 * Author:        Robbie Hatley
 * Edit history:
 *   April 01, 2018: Wrote it.
 \****************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

long double OddProd  (int x);
long double EvenProd (int x);

int main (void)
{
   int          Iterations   = 30;
   int          n            =  0;
   long double  Sum          =  0.0;

   for ( n = 0 ; n < Iterations ; ++n )
   {
      Sum += 6.0 * OddProd(n)
             /
             (EvenProd(n)*(2.0*n+1.0)*pow(2.0,2.0*n+1.0));
      printf("Index = %4d    Sum = %1.17Lf\n", n, Sum);
   }
   return 0;
}

long double OddProd(int x)
{
   int i;
   long double Prod = 1.0;
   for ( i = 1 ; i <= x ; ++i )
   {
      Prod *= (2.0*i-1);
   }
   return Prod;
}

long double EvenProd(int x)
{
   int i;
   long double Prod = 1.0;
   for ( i = 1 ; i <= x ; ++i )
   {
      Prod *= (2.0*i);
   }
   return Prod;
}
