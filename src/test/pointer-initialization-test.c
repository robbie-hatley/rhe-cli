#include <stdlib.h>
#include <stdio.h>
#include <strings.h>
#include <math.h>

int main(int argc, char *argv[])
{
  int **a, *b;
  a =(int **)malloc(sizeof(int *));
  *a=(int  *)malloc(sizeof(int));
  b=*a;
  *b=103;
  printf("a=%p  *a=%p  **a=%i  b=%p  *b=%i", a, *a, **a, b, *b);
  return 0;
}
