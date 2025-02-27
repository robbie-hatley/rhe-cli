/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * Find nth Prime Number
 * Written Aug. 5, 2001 by Robbie Hatley
 * Last updated Sun. June 30, 2002
 * Tests use of fseek() and SEEK_SET for finding things in files.
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>

int main(int argc, char *argv[]) {
  int index;
  char numbstring[15];
  FILE *fp1;
  index=atoi(argv[1])-1;
  fp1=fopen("C:\\D\\Library\\NonFiction\\Mental-Sciences\\Mathematics\\Number-Theory\\first-750000-primes.txt", "r");
  fseek(fp1, (12*index), SEEK_SET);
  fscanf(fp1, "%s", numbstring);
  printf("The %dth prime number is %s\n", index+1, numbstring);
  fclose(fp1);
  return 0;
}

