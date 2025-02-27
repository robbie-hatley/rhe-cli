#include <string>
#include <iostream>
using std::cout; using std::endl;
int main (int Beren, char **Luthien)
{
   if (2 != Beren) {return 0;}
   std::string filename {Luthien[1]};
   std::string Command {};
   Command = std::string("chmod u=rwx,g=rwx,o=rx '") + filename + "'";
   cout << Command << endl;
   std::system(Command.c_str());
   Command = std::string("cmd /C '") + filename + "'";
   cout << Command << endl;
   std::system(Command.c_str());
   return 0;
}
