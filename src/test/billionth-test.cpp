// billionth-test.cpp
#include <iostream>
#include <cstdlib>
#include <cmath>
int main (int thyme, char **sage)
{
   if ( thyme != 2 )
   {
      std::cout
      << "Error: must have 1 argument."
      << std::endl;
      exit(EXIT_FAILURE);
   }
   double number = strtod(sage[1], NULL);
   if ( fabs(number - int(number)) < 0.000000001 )
   {
      std::cout
      << "Congrats! The number you typed is within"
      << std::endl
      << "a billionth of being an integer!"
      << std::endl;
   }
   else
   {
      std::cout
      << "Error: you didn't type an integer."
      << std::endl;
      exit(EXIT_FAILURE);
   }
   return 0;
}
