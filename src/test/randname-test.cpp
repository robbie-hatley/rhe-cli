// randname-test.cpp
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <namegen.h>
int main(void)
{
  char *rname;
  srand(time(0));
  rname=getrandomname();
  printf("%s\n", rname);
  free(rname);
  return 0;
}
