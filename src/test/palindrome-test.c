/* palindrome-test.c */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include "rhmathc.h"

int main (void)
{
   uint64_t Fred  = 39684261;
   uint64_t Ethel = 39688693;
   uint64_t Jack  = 94928563784036373;
   uint64_t Sue   = 94628503730582649;
   
   printf("%lu %s a palindrome.\n", Fred,  IsPalindrome(Fred ) ? "is" : "isn't");
   printf("%lu %s a palindrome.\n", Ethel, IsPalindrome(Ethel) ? "is" : "isn't");
   printf("%lu %s a palindrome.\n", Jack,  IsPalindrome(Jack ) ? "is" : "isn't");
   printf("%lu %s a palindrome.\n", Sue,   IsPalindrome(Sue  ) ? "is" : "isn't");
   printf("Fred: %lu\n", Fred);
   printf("derF: %lu\n", ReverseNumber(Fred));
   return 0;
}
