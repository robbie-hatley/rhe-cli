#include <stdio.h>

int main(void)
{
   int i;
   int Array [2][3][5] = 
   {
      {
         { 0, 1, 2, 3, 4},
         { 5, 6, 7, 8, 9},
         {10,11,12,13,14}
      },
      {
         {15,16,17,18,19},
         {20,21,22,23,24},
         {25,26,27,28,29}
      }
   };
   
   int * Patris = & Array[0][0][0];

   for (i = 0; i< 30; ++i)
   {
      printf("%d, ", (*Patris));
      ++Patris;
   }
   
   return 0;
}
