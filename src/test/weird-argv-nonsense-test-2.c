// weird-argv-nonsense-test-2.c
#include <stdio.h>
#include <stdlib.h>
int main (void)
{
   char * argv [] = {"01234", "5789"}; 
   char ** p = argv;
   printf("%c\n", (*p++)[2]);
   printf("%c\n", (*p++)[2]);
   return 0;
}