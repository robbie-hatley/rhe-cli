#include <iostream>

using std::cin;
using std::cout;
using std::endl;
using std::string;

int main(void) {
   string Text;
   cin >> Text;

   cout << "Length of Text = " << Text.size() << endl;
   cout << "Content of Text = " << Text << endl;
   return 0;
}
