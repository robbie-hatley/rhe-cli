/************************************************************************************************************\
 * Program name:  Random Test
 * Description:   Tests random-number generation techniques.
 * File name:     random-test.c
 * Source for:    random-test.exe
 * Author:        Robbie Hatley
 * Date written:  Tue Sep 30, 2008.
 * Inputs:        Two command-line arguments, which must be positive integers, with the 2nd greater than
 *                the first.  These specify a closed interval [n1, n2] of the natural numbers from which
 *                the output is chosen.  For example, if you type "random 3 8", the output number will be
 *                a random member of the set {3, 4, 5, 6, 7, 8}.
 * Output:        Prints a random member of the subset of the positive integers specified by the arguments.
 *                (See description of inputs, above.)
 * To make:       Just compile with any C compiler.  It's pure ANSI C.  No 3rd-party libraries are used,
 *                but it does use the C Standard Library, so the compiler must support that.
 * Edit history:
\************************************************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char *argv[])
{
   int     LoNum            = 0;
   int     HiNum            = 0;
   int     Span             = 0;
   int     RnNum            = 0;
   int     Shifted          = 0;
   int     Output           = 0;   // Current  random number.
   int     Previous         = 0;   // Previous random number.
   long    Accum            = 0;   // Accumulator for average distance.
   double  MeanDistance     = 0;   // Average distance between consecutive outputs.
   int     i                = 0;
   int     Dev              = 0;
   int     Hash[100]        = {0};
   int     Deviations[201]  = {0};

   /* Seed the random-number generator with the time: */
   srand(time(0));

   /* Get the low and high numbers: */
   LoNum =  0;     /* atoi(argv[1]); */
   HiNum = 99;     /* atoi(argv[2]); */

   /* Get the span: */
   Span  = HiNum - LoNum + 1;

   for ( i = 0 ; i < 100000 ; ++i )
   {
      /* Get random number between 0 and 2147483647 inclusive: */
      RnNum = rand();

      /* Shift RnNum rightward 4 bits: */
      Shifted = RnNum >> 4;

      /* Set Output to (LoNum plus (RnNum modulo Span)): */
      Output = LoNum + Shifted%Span;

      /* Store Output in appropriate hashbucket: */
      ++Hash[Output];

      /* Add distance from previous to accumulator: */
      Accum += abs(Output - Previous);

      /* Save Output in Previous: */
      Previous = Output;
   }

   /* Print all the hash buckets: */
   for (i = 0 ; i < 100 ; ++i)
   {
      printf("Hash bucket #%3d = %3d\n", i, Hash[i]);
      Dev = (int) ( 100.0 * ( ( Hash[i] - 1000.0 ) / 1000.0 ) ) ;
      ++Deviations[100 + Dev];
   }

   /* Print all the deviations: */
   for (i = 0 ; i < 201 ; ++i)
   {
      printf("%4d%% = %3d\n", i-100, Deviations[i]);
   }

   /* Calculate and print the average distance between  */
   /* successive "random" numbers:                      */
   MeanDistance = Accum / 100000.0;
   printf
   (
      "Average distance between consecutive random numbers = %f\n",
      MeanDistance
   );

   return 0;
}
