#include <iostream>
int main(void)
{
   int EvilArray[666];
   EvilArray[0] = 37; 
   EvilArray[1] = 82;
   int* Dagger = &EvilArray[0];
   Dagger = (int*)((char*)Dagger + 2); // alignof(int));
   std::cout << (*Dagger) << std::endl;
   return 0;
}

