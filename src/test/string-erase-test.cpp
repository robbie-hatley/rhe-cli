// string-erase-test.cpp
#include <iostream>
#include <string>
using namespace std;
int main (void)
{
   string Fred = "Fred has a faat ass.";
   Fred.erase(13,1);
   cout << Fred << endl;
   return 0;
}
