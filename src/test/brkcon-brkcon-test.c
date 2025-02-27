// brkcon-brkcon-test.c
#include <stdio.h>
#include <string.h>
int main (void)
{
   char Fred[20][80] = 
   {
      "cat",     "pig",    "rat",    "dog",   "cat", 
      "rat",     "bat",    "horse",  "cow",   "cat",
      "mouse",
   };
   int i;
   for ( i = 0 ; i < 20 ; ++i )
   {
      if (0==strcmp(Fred[i], "cat"))
         continue;
      if (0==strcmp(Fred[i], "rat"))
         continue;
      if (0==strcmp(Fred[i], "horse"))
         break;
      if (0==strcmp(Fred[i], "mouse"))
         break;
      printf("%s\n",Fred[i]);
   }
   return 0;
}