/* cast-test.c */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

int main()
{
   int i;
   float Blat[6] = {9.378, -9.378, 5.835, -5.835, 3.500, -3.500};
   for (i=0 ; i<6 ; ++i)
   {
      printf("Raw number: %f    Cast to int: %d\n", Blat[i], (int)Blat[i]);
   }
   return 0;
}
