#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

typedef struct tagfourchar {
  unsigned char char1;
  unsigned char char2;
  unsigned char char3;
  unsigned char char4;
} fourchar;

typedef union tagfold {
  fourchar ch;
  int in;
} fold;

int main (void)
{
  fold multi;
  multi.ch.char1=0xff;
  multi.ch.char2=0xff;
  multi.ch.char3=0xff;
  multi.ch.char4=0x7f;
  printf("%i", multi.in);
  return 0;
}


