#include <iostream>
#include <string>
namespace bingo {
  int func1() {return 17;}
}
namespace keno {
  std::string boringfunc() {return std::string(" ");}
}
namespace bingo {
  char func2() {return 'Z';}
}
int main() {
  std::cout << bingo::func1();
  std::cout << keno::boringfunc();
  std::cout << bingo::func2() << std::endl;
  return 0;
}
