#include <iostream>
#include <iomanip>
#include <fstream>
#include <vector>
#include <list>
#include <string>
#include <algorithm>
#include <functional>

using namespace std;

// binary function struct:
struct has_letter : public binary_function<string, char, bool>
{ 
  bool operator()(const string& x, const char& a) 
  {
    cout << endl;
    cout << "String = " << x << endl;
    cout << "Letter = " << a << endl;
    if (string::npos!=x.find(a))
    {
      cout << "String \"" << x << "\" has letter \'" << a << "\' ." << endl;
      return true;
    }
    else
    {
      cout << "String \"" << x << "\" does not have letter \'" << a << "\' ." << endl;
      return false;
    }
  }
};

// unary function struct derived from binder2nd<has_letter>:
struct has_arg : public binder2nd<has_letter>
{
  explicit has_arg(char ch)                   // explicit constructor
    : binder2nd<has_letter>(has_letter(), ch) // base-class initializer
    {}                                        // empty constructor body
};

int main(int argc, char *argv[])
{
  char ch=argv[1][0];
  vector<string> animals;
  animals.reserve(100);
  animals.push_back("pig");
  animals.push_back("chicken");
  animals.push_back("dog");
  animals.push_back("wolf");
  animals.push_back("cow");
  animals.push_back("horse");
  animals.push_back("aardvark");
  animals.push_back("zebra");
  animals.push_back("gazelle");
  vector<string>::iterator p = find_if(animals.begin(), animals.end(), has_arg(ch));
  cout << endl;
  if (p!=animals.end()) 
    cout << "Found animal \"" << *p << "\" with letter \'" << ch << "\' !" << endl;
  else 
    cout << "Sorry, did not find an animal with letter \'" << ch << "\' ." << endl;
  return 0;
}
