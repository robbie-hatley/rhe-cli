// middle-character-test-c.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main (int Beren, char * Luthien[])
{
   size_t StringSize;
   if (Beren != 2) {exit(EXIT_FAILURE);}
   StringSize = strlen(Luthien[1]);
   if (StringSize%2 != 1) {exit(EXIT_FAILURE);}
   printf("%c\n", Luthien[1][(StringSize-1)/2]);
   exit(EXIT_SUCCESS);
}
