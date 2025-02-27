#include <iostream>

struct splat {char broiled;};

void Func1(splat par)        {std::cout << par.broiled  << std::endl;}
void Func2(const splat& par) {std::cout << par.broiled  << std::endl;}
void Func3(splat* par)       {std::cout << par->broiled << std::endl;}

int main(void)
{
   splat blat;   // Calls splat's implicit default constructor
   blat.broiled = 'a';
   Func1(blat);  // Calls splat's implicit copy constructor
   Func2(blat);  // Does NOT call any constructors
   Func3(&blat); // Does NOT call any constructors
   std::cout << "C:\deleteme.txt" << std::endl;
   return 0;
}
