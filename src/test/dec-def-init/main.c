#include <stdio.h>
extern int x; // declaration ONLY
extern int y; // declaration ONLY
extern int z; // declaration ONLY
extern void assignx (void);
int main (void) {
   assignx();
   printf("x = %d\n", x); // prints 7
   printf("y = %d\n", y); // prints 13
   printf("z = %d\n", z); // prints ???
   return 0;
}
