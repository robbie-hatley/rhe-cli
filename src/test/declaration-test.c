#include <stdio.h>
#define MAIN_C
#include "globals.h"

unsigned long prng(void);

unsigned long prng(void)
{
  ++seed;
  seed *= 0x87654321;
  return seed >> 7;
}
int main(void)
{
  printf("%lu\n", prng());
  return 0;
}
