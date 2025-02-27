// simple-upper-test.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main (int cnt, char* str[])
{
   if (cnt!=2 || strlen(str[1])!=1 || (int)str[1][0]<97 || (int)str[1][0]>122){exit(666);}
   printf("%c",(char)((int)str[1][0]-32));
   return 0;
} 