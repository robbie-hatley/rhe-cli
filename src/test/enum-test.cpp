#include <iostream>

enum Country {Canada, France, Algeria};

int main()
{
    Country a = Country (Algeria);
    Country b = Country (++Algeria);

    std::cout << a << ", " << b << std::endl;
    return 0;
}
