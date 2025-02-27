/************************************************************************************************************\
 * Program name:  File List Test
 * Description:   Displays contents of file (tests LoadFileToList() in rhutil)
 * File name:     load-file-to-list-test.cpp
 * Source for:    load-file-to-list-test.exe
 * Author:        Robbie Hatley
 * Date written:  Sun. May 2, 2004
 * Edit history:
 *    Sun May 02, 2004
 *    Wed Aug 10, 2005
 *    Wed Sep 17, 2008 - Changed name from "display.cpp" to "load-file-to-list-test.cpp".
 * Inputs:        One command-line argument which must be a valid path to a file
 * Outputs:       Sends contents of file to cout.
 * To make:       Link with rhutil.o in librh.a
\************************************************************************************************************/
#include <iostream>
#include <string>
#include <list>

#include "rhdir.hpp"

using std::cout;
using std::endl;
using std::string;
using std::list;

int main(int, char* argv[])
{
  list<string> L;
  rhdir::LoadFileToList(string(argv[1]), L);
  list<string>::iterator i;
  for (i=L.begin(); i!=L.end(); ++i)
  {
    cout << (*i) << endl;
  }
  return 0;
}
