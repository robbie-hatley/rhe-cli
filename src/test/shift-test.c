/****************************************************************************\
 * shift-test.c
\****************************************************************************/

#include <stdio.h>

int main (void)
{
  int i;
  unsigned char blat=0x80;
  for (i=0; i<8; ++i)
  {
    printf("%i\n", blat);
    blat=blat>>1;
  }
  return 0;
}
