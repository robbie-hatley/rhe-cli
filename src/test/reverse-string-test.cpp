// reverse-string-test.cpp
#include <iostream>
#include <string>
#include <algorithm>
int main (void)
{
    std::string MyString("The rebels are within the walls!");
    std::cout << "Original string: " << MyString << std::endl;
    std::reverse(MyString.begin(), MyString.end());
    std::cout << "Reversed string: " << MyString << std::endl;
    return 0;
}