
// rotate-five-test.c

#include <stdio.h>

void rotate_five (char string[6]) {
   string[5] = string[4];
   string[4] = string[3];
   string[3] = string[2];
   string[2] = string[1];
   string[1] = string[0];
   string[0] = string[5];
   string[5] = '\0';
   return;
}

int main (void) {
   char string[6] = {'1','2','3','4','5','\0'};
   printf("Original string = \"%s\"\n", string);
   printf("All rotations of that original string follow:\n");
   for ( int i = 0 ; i < 5 ; ++i ) {
      rotate_five(string);
      printf("%s\n",string);
   }
   return 0;
}
