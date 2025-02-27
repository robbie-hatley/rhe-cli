// substitute-characters-in-string-test-cpp.cpp
#include <iostream>
#include <string>
int main (void)
{
   std::string MyString  ("My dog has flees!");

   std::cout << "Original string: " << MyString << std::endl;

   // Fix spelling error:
   MyString[14] = 'a';

   std::cout << "Corrected string: " << MyString << std::endl;

   // Substitute "parrot" for "dog":
   MyString.replace(3, 3, "parrot");

   std::cout << "Altered string: " << MyString << std::endl;
   return 0;
}