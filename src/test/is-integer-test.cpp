/************************************************************************************************************\
 * File name:       is-integer.cpp
 * Source for:      is-integer.exe
 * Program name:    Is String An Integer?
 * Author:          Robbie Hatley
 * Date written:    Fri. May. 27, 2005
 * Input:           A string typed-in from the keyboard.
 * Output:          Prints "Yes." if the input string was an integer; otherwise, prints "No.".
 * To make:         Link with module rhutil.o in librh.a
\************************************************************************************************************/

#include <iostream>
#include <cstdlib>
#include <string>

#include "rhutil.hpp"

int main(void)
{
   using std::cout;
   using std::endl;
   using std::cin;
   std::string NumStr;
   getline(cin, NumStr);
   if(rhutil::IsInteger(NumStr))
   {
      cout << "Yes." << endl;
      cout << "Value = " << atof(NumStr.c_str()) << endl;
   }
   else
   {
      cout << "No." << endl;
      cout << "Value = " << atof(NumStr.c_str()) << endl;
   }
   return 0;
}
