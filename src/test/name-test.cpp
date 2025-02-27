#include <iostream>
#include <string>

using std::cin;
using std::cout;
using std::endl;
int main(void)
{
   //Welcome user:
   cout << "Welcome to my first program!"             << endl;
   cout << "I hope I can do some pretty neat things!" << endl;

   //Get user's name and introduce myself:
   std::string name;
   cout << "So we can be more formal, please tell me your name: " << endl;
   getline(cin, name);

   //Greet user by name:
   cout << "Why, hello there, " << name << "! How are you doing?" << endl;
   return 0;
}
