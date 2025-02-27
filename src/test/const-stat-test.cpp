
// const-stat-test.cpp

#include <iostream>
#include <string>

double             Fred  = 16;      // Variable
const int          Susan = 17;      // Constant

static int         Jim   = 42;      // static
const double       Ellen = 19.4;    // constant
static const float Ngubu = 13.7F;   // both
std::string        Text  = "apple"; // neither

int main (void)
{
   double Allison =
   32.4  * Fred
   - 17.2  * Susan
   + 1.7   * Jim
   - 6.2   * Ellen
   + 0.16  * Ngubu;
   std::cout << Allison << std::endl;
   std::cout << Text    << std::endl;
   return 0;
}
