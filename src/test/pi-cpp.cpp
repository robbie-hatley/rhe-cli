/* This is a 79-character-wide ASCII C source-code text file.                */
/*=======|=========|=========|=========|=========|=========|=========|=======*/

/*****************************************************************************\
 * File name:     pi.cpp
 * Description:   Fast series for Pi, unlimited-precision.
 * Author:        Robbie Hatley
 * Edit history:
 *   Tue May 29, 2018: Wrote it.
 \****************************************************************************/

#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <cmath>
#include <gmp.h>

using namespace std;

void OddProd (mpf_t Odd, const uint64_t n);
void EvnProd (mpf_t Evn, const uint64_t n);
void Help (void);

int main (int Beren, char * Luthien[])
{
   // Declare, define, and initialize fixed-precision variables:
   uint64_t  Digits      = 100;  // number of significant digits
   uint64_t  Iterations  = 200;  // number of iterations
   uint64_t  Bits        = 512;  // number of bits
   uint64_t  Input       =   0;  // user input
   uint64_t  n           =   0;  // sum term index
   uint64_t  Two         =   0;  // 2n+1
   
   // Declare unlimited-precision variables:
   mpf_t     Odd;                // odd product
   mpf_t     Evn;                // evn product
   mpf_t     Num;                // numerator
   mpf_t     Den;                // denominator
   mpf_t     Quo;                // quotient
   mpf_t     Sum;                // sum

   // If user wants help, just print help and exit:
   if
      (
         Beren > 1
         &&
         (
            0 == strcmp(Luthien[1], "-h")
            ||
            0 == strcmp(Luthien[1], "--help")
         )
      )
   {
      Help();
      exit(EXIT_SUCCESS);
   }

   // Before initializing extended-precision variables, set Digits, Bits, and
   // Iterations if user has indicated a valid number of digits:
   if (Beren > 1 && '-' != Luthien[1][0])
   {
      Input = strtoul(Luthien[1], NULL, 10);
      if (Input < 1UL)
          Input = 1UL;
      if (Input > 1000000000UL)
          Input = 1000000000UL;
      Digits = Input;
      // Bits-necessary = (ln(10)/ln(2)) * Digits = about 3.322 * Digits,
      // but use 3.5 * Digits, rounded up to nearest multiple of 64:
      Bits = (uint64_t)(64.0*ceil(3.5*(double)Digits/64.0));
      // Use Iterations = 1.75 * Digits:
      Iterations = (uint64_t)(1.75 * (double)Digits);
   }

   // Set precision:
   mpf_set_default_prec(Bits);

   // Initialize all extended-precision variables:
   mpf_init(Odd);
   mpf_init(Evn);
   mpf_init(Num);
   mpf_init(Den);
   mpf_init(Quo);
   mpf_init(Sum);

   // Sum n:0->inf 6(OddProd(n))/(EvenProd(n)*(2.0*n+1.0)*pow(2.0,2.0*n+1.0)) 
   for ( n = 0 ; n < Iterations ; ++n )
   {
      // Get odd product:
      OddProd(Odd, n);

      // Get evn product:
      EvnProd(Evn, n);

      // Get numerator:
      mpf_mul_ui(Num, Odd, 6);

      // Get 2n+1:
      Two = 2UL * n + 1UL ;

      // Get denominator:
      mpf_mul_ui(Den, Evn, Two);
      mpf_mul_2exp(Den, Den, Two);

      // Get quotient:
      mpf_div(Quo, Num, Den);

      // Append quotient to sum:
      mpf_add(Sum, Sum, Quo);

      // Print each partial result:
    //printf("iter = %5lu  pi = ", n);
    //gmp_printf("%1.*Ff\n", Digits-1, Sum);
   }
   gmp_printf("%1.*Ff\n", (uint64_t)((double)n/1.75), Sum);
   exit(EXIT_SUCCESS);
}

// 1*3*5*... (0,1,2,3,4,5 -> 1,1,3,15,105,947)
void OddProd (mpf_t Odd, const uint64_t n)
{
   uint64_t i;
   mpf_set_ui(Odd, 1);
   for ( i = 1 ; i <= n ; ++i )
   {
      mpf_mul_ui(Odd, Odd, 2UL*i-1UL);
   }
}

// 2*4*6*... (0,1,2,3,4,5 -> 1,2,8,48,384,3840)
void EvnProd (mpf_t Evn, const uint64_t n)
{
   uint64_t i;
   mpf_set_ui(Evn, 1);
   for ( i = 1 ; i <= n ; ++i )
   {
      mpf_mul_ui(Evn, Evn, 2UL*i);
   }
}

void Help (void)
{
   fprintf
   (
      stdout, 
      "Welcome to \"pi\", Robbie Hatley's nifty pi-printing program.\n"
      "This program takes one optional argument, which should be an integer\n"
      "in the 1-1,000,000,000 range, indicating the number of significant\n"
      "digits of pi to compute and print. (All arguments after the first\n"
      "will be ignored.) If no argument, or an invalid argument, is given,\n"
      "then this program will print the first 100 significant digits of pi."
   );
}
