// repre-test.c
#include <stdio.h>
#include <stdlib.h>
int main (int Beren, char ** Luthien)
{
   long Fred;
   if (Beren != 2) {exit(EXIT_FAILURE);}
   Fred = strtol(Luthien[1], NULL, 10);
   Fred *= 2; // Double the value of Fred.
   printf("Double = %ld\n", Fred);
   exit(EXIT_SUCCESS);
}