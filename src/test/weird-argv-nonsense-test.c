// weird-argv-nonsense-test.c
#include <stdio.h>
#include <stdlib.h>
int main (void)
{
   char * argv [] = {"01234", "5789"}; 
   char ** p = argv;
   printf("%c\n", **p);
   printf("%c\n", (*p++)[2]);
   return 0;
}