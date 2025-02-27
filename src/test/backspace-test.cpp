#include <iostream>

void Backspace(int N);

int main()
{
   std::cout << "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
   Backspace(3);
   std::cout << "123" << std::endl;
   return 0;
}

void Backspace(int N)
{
   for (int i = 0; i < N; ++i)
   {
      std::cout << char(8);
   }
   return;
}
