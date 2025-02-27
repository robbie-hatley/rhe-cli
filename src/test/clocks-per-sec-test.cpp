#include <iostream>
#include <ctime>

int main(void)
{
  std::cout
    << "Clocks per second = " << CLOCKS_PER_SEC << std::endl
    << "clock() = " << clock << std::endl
    << "time()  = " << time(0) << std::endl;
  return 0;
}
