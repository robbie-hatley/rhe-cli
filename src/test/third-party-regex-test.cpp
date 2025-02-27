// third-party-regex-test.cpp
#include <iostream>
#include <string>
#include <regex>

int main ()
{

  std::regex  e ("(sub)(.*)");
  std::string s ("subject");
  std::smatch sm;    // same as std::match_results<string::const_iterator> sm;
  std::regex_match (s,sm,e);
  std::cout << "Number of matches = " << sm.size() << std::endl;
  std::cout << "The matches were: " << std::endl;
  for (unsigned i=0; i<sm.size(); ++i)
  {
    std::cout << sm[i] << std::endl;
  }

  return 0;
}