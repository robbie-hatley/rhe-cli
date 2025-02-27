// parameter-input-output-test.cpp
#include <iostream>
#include <vector>
#include <string>

// The first parameter of this function is an input,
// so I'm using a constant reference to indicate that
// this function does not alter that referent.
// But the second and third parameters are outputs,
// so I'm using NON-constant references to indicate that
// this function DOES alter those referents.
void min_max
   (
      const std::vector<double> & numbers, // const ref
            double              & min,     // non-const ref
            double              & max      // non-const ref
   )
{
   if (numbers.empty())
   {
      min = 0.0;
      max = 0.0;
   }
   else
   {
      min = max = numbers.at(0);
      for (double number : numbers)
      {
         if (number < min)
            min = number;
         if (number > max)
            max = number;
      }
   }
   return;
}

int main (void)
{
   std::vector<double> Fred {3.3, 8.2, 97.6, -87.4, 13.9};
   double Minimum, Maximum;
   min_max(Fred, Minimum, Maximum);
   std::cout
      << "min = " << Minimum << std::endl
      << "max = " << Maximum << std::endl;
   return 0;
}
