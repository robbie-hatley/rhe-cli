/* This is a 110-character-wide ASCII C source-code text file.                                              */
/*=======|=========|=========|=========|=========|=========|=========|=========|=========|=========|======= */

/************************************************************************************************************\
 * Program name:  mult35
 * Description:   Prints sum of all natural numbers under 1000 which are multiples of 3 or 5.
 * File name:     mult35.c
 * Source for:    mult35.exe
 * Author:        Robbie Hatley
 * Date written:  2013-05-06
 * Edited:        2025-11-27
 * Inputs:        None.
 * Outputs:       Prints sum of all natural numbers under 1000 which are multiples of 3 or 5.
 * To make:       Compile with GCC
\************************************************************************************************************/

#include <stdio.h>
#include <stdlib.h>

int main(void)
{
   long int Accum      = 0;
   long int i          = 0;
   Accum+=3;
   Accum+=5;
   for (i=6;i<1000;++i)
   {
      if ((0==i%3)||(0==i%5))
      {
         Accum+=i;
      }
   }
   printf("Sum of all multiples of 3 and 5 under 1000 = %8ld\n", Accum);
   return 0;
}
