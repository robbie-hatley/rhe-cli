// accursed-test.c
#include <stdio.h>
void accursed (void) {
   char ugly[80];
   printf("%s\n", ugly);
   return;
}
int main (void) {
   accursed();
   return 0;
}
