#include <initializer_list>
#include <iostream>
#include <ostream>
#include <string>
#include <regex>
#include <thread>
#include <memory>
void alpha() {
   std::cout << "alpha\n";
}
int main(void)
{ 
   std::unique_ptr<std::string> s =
      std::make_unique<std::string>("string");
   std::regex pat {R"(\w{2}\s*\d{5}(-\d{4})?)"};
   std::cout << std::string("examples").find('x') << std::endl; 
   std::thread t(alpha); 
   t.join(); 
   return 0;
}
