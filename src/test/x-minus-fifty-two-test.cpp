// x-minus-fifty-two-test.cpp
#include <iostream>
int main (int Beren, char *Luthien[])
{
   int    i;
   double x;
   for ( i = 1 ; i < Beren ; ++i )
   {
      x = strtod(Luthien[i], NULL);
      std::cout 
         << "f(" 
         << x 
         << ") = " 
         << 52 - x 
         << std::endl;
   }
   return 0;
}
