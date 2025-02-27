#include <stdio.h>
#include <stdlib.h>
#include <string.h>

union blat
{
  unsigned long int i;
  char c[4];
};

int main(void)
{
  union blat asdf;
  strcpy(asdf.c, "yuio");
  printf("string:  %c%c%c%c\n", asdf.c[0], asdf.c[1], asdf.c[2], asdf.c[3]);
  printf("integer: %lu\n", asdf.i);
  return 0;
}

