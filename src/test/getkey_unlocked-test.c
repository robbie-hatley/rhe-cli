// getkey_unlocked-test.c
#include <stdio.h>
#include <stdlib.h>
#include "rhutilc.h"
int main (void)
{
   char    c = 0;
   double t0 = 0.0;
   double t1 = 0.0;
   double t2 = 0.0;

   t0 = HiResTime();
   t1 = t0;
   t2 = t1;

   system("stty -icanon");
   system("stty -echo");
   system("stty time 1");

   while (42)
   {
      t2 = HiResTime();
      if (t2 - t1 > 1.0)
      {
         c = (char)getchar();
         printf("c = %d\n", (int)c);
         t1 = t2;
      }
      if (t2-t0 > 10.1)
         break;
   }

   system("stty echo");
   system("stty icanon");

   return 0;
}
