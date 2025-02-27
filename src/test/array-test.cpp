// array-test.cpp
// CONTAINS BAD CODE!!! DON'T PROGRAM LIKE THIS!!!
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
int main (void)
{
   // Make a stupid, brain-dead C-style array in a C++ program,
   // even though it's totally obsolte and exceedingly dangerous:
   int MyStupidArray[100] = {0};

   // Make an index variable for our crappy array:
   size_t i = 0;

   // Seed the random number generator:
   srand(unsigned(time(NULL)));

   // Load 100 random ints into our stupid array:
   for ( i = 0 ; i < 100 ; ++i ) // If you get this wrong, you
   {                             // may crash your computer!!!
      MyStupidArray[i] = rand(); // Memory corruption danger
   }                             // if i is incorrect!!!

   // Print contents of our stupid array:
   for ( i = 0 ; i < 100 ; ++i )
   {
      printf("%d\n", MyStupidArray[i]);
   }

   // We're done acting like obnoxious morons, so let's exit:
   return 0;
}
