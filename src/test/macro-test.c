// macro-test.c

#include <stdio.h>
#include <string.h>

#define MYCAT(a,b,c,d,e) ID ## _ ## a ## _ ## b ## _ ## c ## _ ## d ## _ ## e

int main (void) 
{
   char ID[128];
   strcpy(ID, MYCAT(2020,11,17,Robbie,Hatley));
   printf("%s\n", ID);
   return 0;
}
