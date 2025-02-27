/************************************************************************************************************\
 * Program name:  postfix-test
 * Description:   tests postfix ++ operator
 * File name:     postfix-test.cpp
 * Source for:    postfix-test.exe
 * Author:        Robbie Hatley
 * Date written:  2004-05-08
 * Last edited:   2004-05-08
\************************************************************************************************************/

#include <iostream>

using std::cout;
using std::endl;

int main(int argc, char* argv[])
{
  int i = 5;
  int j = 5;
  cout << "i before incrementing = " << i << endl;
  cout << "j before incrementing = " << i << endl;
  i++ = j;
  cout << "i after \"i++ = j;\" = " << i << endl;
  cout << "j after \"i++ = j;\" = " << j << endl;
  return 0;
}
