// string-test.cpp
#include <iostream>
#include <string>

using namespace std;

int main (void)
{
   string MyString ("Hello");
   MyString += ", World!";
   cout << MyString << endl;
   return 0;
}
