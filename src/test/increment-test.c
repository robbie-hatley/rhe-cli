#include <stdio.h>
int main (void) {
   int x = 3;  // x starts at 3.
   int y = 0;  // Always initialize!!!
   ++x;        // Increment x to 4.
   y += 2*x;   // y is now 8.
   ++x;        // x is now 5.
   printf ("x = %d, y = %d\n", x, y);
   return 0;
}
