/************************************************************************************************************\
 * File name:       is-simple-number.cpp
 * Source for:      is-simple-number.exe
 * Program name:    Is String A Simple Number?
 * Author:          Robbie Hatley
 * Date written:    Fri. May. 27, 2005
 * Input:           A string typed-in from the keyboard.
 * Output:          Prints "Yes." if the input string was a simple number (non-scientific notation);
 *                  otherwise prints "No.".
 * 
 * To make:         Link with module rhutil.o in librh.a
 * 
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
   if(rhutil::IsSimpleNumber(NumStr))
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
