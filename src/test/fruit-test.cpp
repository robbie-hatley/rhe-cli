// fruit-test.cpp
#include <string>
#include <iostream>

bool IsYummyFruit(const std::string& sprat)
{
   return sprat == "orange" or sprat == "apple" or sprat == "banana";
}

bool IsYuckyFruit(const std::string& sprat)
{
   return sprat == "guava" || sprat == "persimmon" || sprat == "breadfruit";
}

int main(int argc, char* argv[])
{
   using std::string;
   using std::cout;  
   using std::endl;
   string Object (argv[1]);
   if (IsYummyFruit(Object))
   {
      cout << "Yummy!" << endl;
   }
   else if (IsYuckyFruit(Object))
   {
      cout << "Eww, yuck!" << endl;
   }
   else
   {
      cout << "YOU CAN\'T EAT THAT!!!!!" << endl;
   }
   return 42;
}

