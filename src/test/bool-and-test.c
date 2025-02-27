// bool-and-test.c
#include <stdio.h>
#include <stdbool.h>
int main (void)
{
   bool A = true;
   bool B = true;
   bool C = true;
   bool D = false;
   bool E;
   E = A && B && C && D; // 4-input AND
   // With these input values, the AND must test
   // all 4 inputs, because the first 3 are true.
   if (E)
   {
      printf("True!\n"); // won't print
   }
   else
   {
      printf("False!\n"); // THIS prints
   }
   A = true;
   B = false;
   C = false;
   D = true;
   E = A && B && C && D; // 4-input AND
   // With these input values, the AND must test
   // just 2 inputs, because the second is false.
   if (E)
   {
      printf("True!\n"); // won't print
   }
   else
   {
      printf("False!\n"); // THIS prints
   }
   return 0;
}
