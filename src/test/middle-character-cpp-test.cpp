// middle-character-test-cpp.cpp
#include <iostream>
#include <string>
using namespace std;
int main (int Beren, char * Luthien[])
{
   if (Beren != 2) {exit(EXIT_FAILURE);}
   string MyString (Luthien[1]);
   if (MyString.size()%2 != 1) {exit(EXIT_FAILURE);}
   cout << MyString[(MyString.size()-1)/2] << endl;
   exit(EXIT_SUCCESS);
}
