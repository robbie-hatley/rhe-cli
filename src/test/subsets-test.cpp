#include <string>
#include <iostream>

int main()
{
    std::string fullset("abcd");

    std::string subset;
    int all = (1 << fullset.size()) - 1;
    for (int k = 1; k <= all; ++k, subset.erase())
    {
        for (int i = 0; (1 << i) < all; ++i)
            subset.append( (k & (1 << i)) != 0, fullset[i] );

        std::cout << subset << std::endl;
    }
}
