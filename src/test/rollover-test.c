#include <stdlib.h>
#include <stdio.h>

int main(void)
{
  int i=0;
  int a=2147483646;
  unsigned int b=2147483646;
  for (i=0; i<7; ++i)
  {
    printf("a = %i\n", a++);
    printf("b = %u\n\n", b++);
  }
  return 0;
}

