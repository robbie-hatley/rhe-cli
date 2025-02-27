/****************************************************************************\
 * File name:     static-const-member-vector-test.cpp
 * Authorship:    Written Saturday May 3, 2003, by Robbie Hatley
 * Last edited:   Saturday May 3, 2003
\****************************************************************************/

#include <iostream>
#include <vector>
#include <string>
#include <stdexcept>

using std::cout;
using std::endl;
using std::string;
using std::vector;
using std::out_of_range;

namespace Tspace 
{
  class Test
  {
    public:
      static void setblat(int x, int y, string asdf)
      {
        blat.at(x).at(y) = asdf;
      }
      static void printblat(int x, int y)
      {
        cout << blat.at(x).at(y) << endl;
      }
      static vector<vector<string> > blat;
  };
} // end namespace Tspace

vector<vector<string> > Tspace::Test::blat (3, vector<string> (5));


int main(int argc, char *argv[])
{
  Tspace::Test::blat[1][2]=(string)"Deum";
  
  try
  {
    Tspace::Test::setblat(2, 2, "Gloria");
  }
  catch (out_of_range)
  {
    cout
      << "Oops!  There was an out-of-range exception in setblat()!"
      << endl;
  }
  
  try
  {
    Tspace::Test::printblat(2, 2);
  }
  catch (out_of_range)
  {
    cout
      << "Oops!  There was an out-of-range exception in printblat()!"
      << endl;
  }
  
  try
  {
    Tspace::Test::setblat(1, 1, "excelcis");
  }
  catch (out_of_range)
  {
    cout
      << "Oops!  There was an out-of-range exception in setblat()!"
      << endl;
  }
  
  try
  {
    Tspace::Test::printblat(1, 1);
  }
  catch (out_of_range)
  {
    cout
      << "Oops!  There was an out-of-range exception in printblat()!"
      << endl;
  }
  
  return 0;
}
