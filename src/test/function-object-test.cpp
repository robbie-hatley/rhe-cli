/****************************************************************************\
 * File name:   function-object-test.cpp
 * Title:       
 * Authorship:  RH, Sun. Jan. 12, 2003
 * Description: 
 * Inputs:      
 * Outputs:     
 * Notes:       
 * To make:     
\****************************************************************************/

#include <iostream>
#include <iomanip>
#include <fstream>
#include <vector>
#include <list>
#include <string>
#include <algorithm>
#include <functional>

#include "..\lib\mathutil.hpp"

using namespace std;

class tquadratic
{
  public:
    explicit tquadratic(const double& aa, const double& bb, const double& cc)
      : a (aa) , b (bb) , c (cc) {}
    inline double operator()(const double& x) const {return a*x*x + b*x + c ;}
  private:
    double a;
    double b;
    double c;
};

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
  explicit has_arg(char ch)                   // Explicit constructor.
    : binder2nd<has_letter>(has_letter(), ch) // Base-class initializer.
    {}                                        // Empty constructor body.
                                              // Inherits application operator
                                              // from binder2nd.
};

int main(int argc, char *argv[])
{
  char ch=argv[1][0];
  tquadratic aquad (2.7, -3.9, 4.5);
  Randomize();
  cout << aquad(RandNum(-25.0, 25.0)) << endl;
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
  
  cout << endl;
  cout << " Number  of  animals = " << animals.size()     << endl;
  cout << "Capacity for animals = " << animals.capacity() << endl;
  
  vector<string>::iterator p=find_if(animals.begin(), animals.end(), has_arg(ch));
  
  cout << endl;
  if (p!=animals.end()) 
    cout << "Found animal \"" << *p << "\" with letter \'" << ch << "\' !" << endl;
  else 
    cout << "Sorry, did not find an animal with letter \'" << ch << "\' ." << endl;
  return 0;
}
