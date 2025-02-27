
// enum-cpp-test.cpp

#include <iostream>

typedef enum
{
   Canada, 
   France, 
   Algeria,
}Country;

int main (void)
{
    Country a = Algeria;
    Country b = France;

    std::cout << a << ", " << b << std::endl;
    return 0;
}
