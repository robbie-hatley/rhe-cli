#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

int main (void)
{
  int array[5][7];
  int i, j;
  for (i=0;i<5;++i) {
    for (j=0;j<7;++j) {
      array[i][j]=j+7*i;
    }
  }
  for (i=0;i<5;++i) {
    for (j=0;j<7;++j) {
      printf("&array[%d][%d]=%p   array[%d][%d]=%2d\n",
        i, j, &array[i][j], i, j, array[i][j]);
    }
  }
  for (i=0;i<5;++i) {
    printf("array[%d]=%p\n", i, array[i]);
  }
  return 0;
}

