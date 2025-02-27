/****************************************************************************\
 * Project name:  std::string::npos test
 * File name:     C:\C\test\npos.cpp
 * Author:        Robbie Hatley
 * Date written:  Sun. Jan. 18, 2004
 * Last edited:   Sun. Jan. 18, 2004
 * Description:   Prints value of std::string::npos
 * To make:       No dependencies other than std. lib..
\****************************************************************************/

#include <iostream>
#include <string>

using std::cout;
using std::endl;
using std::string;

int main(void)
{
  cout << string::npos << endl;
  return 0;
}
