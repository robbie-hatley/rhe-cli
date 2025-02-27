#include <iostream>
#include <vector>
#include <new>

int main(void)
{
   std::vector<unsigned long int>* Andy = new std::vector<unsigned long int>[100];
   
   int AndyCap;
   
   AndyCap = 0;
   for (int i=0; i<100; ++i) AndyCap += Andy[i].capacity();
   std::cout << "Size of Andy is " << (AndyCap*sizeof(unsigned long int)) << std::endl;
   
   for (int i=0; i<100; ++i) Andy[i].reserve(1000);
   
   AndyCap = 0;
   for (int i=0; i<100; ++i) AndyCap += Andy[i].capacity();
   std::cout << "Size of Andy is " << (AndyCap*sizeof(unsigned long int)) << std::endl;
   
   delete[] Andy;
   
   return 0;
}
