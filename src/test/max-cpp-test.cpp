// "max.cpp"
#include <iostream>
#include <vector>
using namespace std;
int main (int Beren, char * Luthien[])
{
   // Declare variables:
   int           i        = 0;
   long          max      = 0;
   vector<long>  numbers;

   // Exit if fewer than 2 numbers entered:
   if (Beren < 3) exit(EXIT_FAILURE);

   // Extract numbers from command-line and put in "numbers":
   for ( i = 0 ; i < Beren-1 ; ++i )
   {
      numbers.push_back(strtol(Luthien[i+1], NULL, 10));
   }

   // Find max:
   for ( i = 0 ; i < Beren-1 ; ++i )
   {
      if (numbers[i] > max) max = numbers[i];
   }

   // Print max:
   printf("%ld", max);

   // Exit program:
   return 0;
}
