// vector-test.cpp
#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>
int main (void)
{
   // Make a vector and reserve 50 elements for it,
   // even though we're going to use 100 elements;
   // it can't overflow; it will reallocate itself
   // when it gets full; memory corruption can never
   // happen:
   std::vector<int> MyVec;
   MyVec.reserve(50);

   // Seed the random number generator:
   srand(unsigned(time(NULL)));

   // Make a counter variable:
   size_t count = 0;

   // Load 100 random ints into vector:
   while (count++ < 100)
   {
      MyVec.push_back(rand());
      std::cout 
      << "Vector capacity = " << MyVec.capacity() << "; "
      << "Vector size     = " << MyVec.size() << std::endl;
   }

   // Print contents of vector:
   for (int x : MyVec) {std::cout << x << std::endl;}

   return 0;
}