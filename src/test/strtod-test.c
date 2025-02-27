#include <stdio.h>
#include <stdlib.h>

int main (void)
{
   double Value1 = strtod("00000456.789", NULL);
   printf("%14.5f\n", Value1);
   char buf [30] = "V 5.7z";
   double Value2 = strtod(&buf[1], NULL);
   printf("%4.1f\n", Value2);
   return 0;
}
