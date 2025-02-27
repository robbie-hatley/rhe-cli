// zero-two-bits-test.c
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
int main (int Beren, char * Luthien[])
{
   if (3 != Beren)
      exit(EXIT_FAILURE);
   uint16_t s = (uint16_t)strtol(Luthien[1], NULL, 10);
   uint16_t n = (uint16_t)strtol(Luthien[2], NULL, 10);
   printf("%d\n", (int)(s & ~(3<<n)));
   exit(EXIT_SUCCESS);
}
