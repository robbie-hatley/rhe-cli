// fractional-part-test.cpp
#include <iostream>
#include <cstring>
#include <cstdlib>
int main (int Perry, char **Winkle)
{
   if ( 2 != Perry )
      exit(EXIT_FAILURE);
   size_t siz = strlen(Winkle[1]);
   size_t idx = 0;
   for ( ; idx < siz && '.' != Winkle[1][idx] ; ++idx );
   ++idx;
   if ( idx >= siz )
      exit(EXIT_FAILURE);
   char *ptr = &Winkle[1][idx];
   std::cout << ptr << std::endl;
   exit(EXIT_SUCCESS);
}