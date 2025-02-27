/* This is a 79-character-wide ASCII C source-code text file.                */
/*=======|=========|=========|=========|=========|=========|=========|=======*/

/***************************************************************************************\
 * File name:     pi-slow-test.c
 * Description:   Tests convergence of series 4/1 - 4/3 + 4/5 - 4/7 + 4/9 ... to pi.
 * Date written:  2001-06-24
 * Edit history:
 *        Jun 24, 2001 - Wrote it.
 *    Sat Oct 23, 2004 - Edited it.
 *    Mon Apr 06, 2015 - Corrected above formula, which was wrong. The formula in the
 *                       comment was "4 - 1/2 + 1/3 - 1/4..." which does NOT 
 *                       converge to pi. (It converges, but to 3+ln2, not pi.) 
 *                       The formula 4/1 - 4/3 + 4/5 - 4/7..., however, 
 *                       DOES converge to pi, but exceedingly slowly (takes 500,000 
 *                       iterations just to get 6 sig figs of accuracy). Ironically,
 *                       the formula actually in the code was correct; just the comment
 *                       above was wrong; now corrected.
 \***************************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <strings.h>
#include <math.h>

int main(int argc, char *argv[])
{
   long         i      =   0L; 
   long         limit  =  10L;
   long double    v    = 0.0L;

   if (argc >= 2)
   {
      limit = strtol(argv[1], NULL, 10);
   }

   printf("Convergence test of series 4/1 - 4/3 + 4/5 - 4/7...:\n");


   for ( i = 0 ; i <= limit ; ++i )
   {
      /*    v = v + sign*4/(2i+1)    */
      v = v + (2L*((i+1L)%2L)-1L) * 4.0L / (2L*i+1L);
      printf("i = %6li          v = %1.8Lf\n", i, v);
   }
   return 0;
}
