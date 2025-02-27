// unique-test.cpp
#include <iostream>
#include <cstdlib>
#include <list>
int main (void)
{
   int temp_rand = 0;
   int i = 0;
   std::list<int> unique;
   std::list<int>::iterator n;

   srand(unsigned(time(NULL)));

   for ( i = 1 ; i <= 1000 ; ++i )
   {
      TRY_AGAIN:
      temp_rand = rand();
      for ( n = unique.begin() ; n != unique.end() ; ++n )
      {
         if (temp_rand == *n)
         {
            std::cout << "DUPLICATE!!!" << std::endl;
            goto TRY_AGAIN;
         }
      }
      unique.push_back(temp_rand);
   }

   for ( n = unique.begin() ; n != unique.end() ; ++n )
   {
      std::cout << *n << std::endl;
   }

   exit(EXIT_SUCCESS);
}
