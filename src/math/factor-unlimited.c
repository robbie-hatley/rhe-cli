/************************************************************************************************************\
 * File name:    factor-unlimited.c
 * Lexicology :  This is a 110-character-wide ASCII-encoded C source-code file.
 * Title:        Factor
 * Description:  Factors integers.
 * Input:        One command line argument, which must be an integer >= 2 (no upper limit).
 * Output:       The prime factors of the number given as input.
 * Dependencies: Gnu C std lib 2011; -D_GNU_SOURCE; GMP.
 * Author:       Robbie Hatley
 * Edit history:
 *    Tue Jan 28, 2003: Wrote it.
 *    Sat Oct 23, 2004: Edited.
 *    Sun Feb 14, 2016: Edited.
 *    Sun Nov 15, 2020: Converted to ASCII, C, and GMP.
 *    Mon Apr 06, 2026: Dramatically sped-up by only testing up to square root of remainder.
\************************************************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <gmp.h>

int main(int Beren, char** Luthien)
{
   mpz_t i; mpz_init(i); // Index for "for" loop.
   mpz_t x; mpz_init(x); // Number to be factored.

   if (Beren != 2) {
      fprintf(stderr, "Error: factor takes exactly one argument, which must be an integer >= 2.");
      fflush(stderr);
      exit(EXIT_FAILURE);
   }

   mpz_set_str(x, Luthien[1], 10);

   if (mpz_cmp_ui(x, 2ul) < 0) {
      fprintf(stderr, "Error: factor takes exactly one argument, which must be an integer >= 2.");
      fflush(stderr);
      exit(EXIT_FAILURE);
   }

   gmp_printf("prime factors of %Zd: \n", x);
   fflush(stdout);

   mpz_set_si(i, 2ul);
   while (mpz_divisible_p(x,i)) {
      mpz_fdiv_q(x,x,i);
      printf(" 2");
      fflush(stdout);
   }

   mpz_t sq;
   mpz_init(sq);
   for ( mpz_set_ui(i, 3ul) ; mpz_mul(sq,i,i),mpz_cmp(sq,x) <= 0 ; mpz_add_ui(i,i,2ul) ) {
      while (mpz_divisible_p(x,i)) {
         mpz_fdiv_q(x,x,i);
         gmp_printf(" %Zd", i);
         fflush(stdout);
      }
   }
   if ( mpz_cmp_si(x,1) != 0 ) {
      gmp_printf(" %Zd", x);;
      fflush(stdout);
   }
   printf("\n");
   fflush(stdout);

   exit(EXIT_SUCCESS);
}
