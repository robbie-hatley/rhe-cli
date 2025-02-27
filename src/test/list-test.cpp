// list-test.cpp
#include <iostream>
#include <string>
#include <list>
using std::cout;
using std::endl;
using std::string;
using std::list;
int main(void)
{
  list<string> L;
  L.push_back("Sue");
  L.push_back("Tom");
  L.push_back("Sam");
  L.push_back("Elen");
  L.push_back("Elizabeth");
  list<string>::iterator i;
  for (i=L.begin(); i!=L.end(); ++i)
  {
    cout << (*i) << endl;
  }
  return 0;
}
