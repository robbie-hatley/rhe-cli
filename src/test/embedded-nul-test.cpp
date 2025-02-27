#include<iostream>
using namespace std;
int main (void) 
{
   string s = "samxple text";
   s[3] = '\0';
   cout << "Length of s = " << s.length() << endl;
   cout << "s = " << s << endl;
   return 0;
}