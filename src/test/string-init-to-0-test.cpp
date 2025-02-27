#include <iostream>
#include <string>
using std::cout; 
using std::endl;
int main (void)
{
   cout << "anaphylaxis" << endl;
   std::string s = 0;                  // This pointer points NOWHERE.
   cout << "brachiocephalic" << endl;
   s = "chameleon";                    // Let's crash the system!!! WHEEE!!!
   cout << s << endl;
   return 0;
}
