// comp-char-test.cpp
#include <iostream>
using namespace std;
int main ()
{
   char     ac  = '\0';  // character a
   char     bc  = '\0';  // character b
   uint8_t  a   = 0;     // int version of a
   uint8_t  b   = 0;     // int version of b

   // Prompt user to input two characters:
   cout << "Enter two characters." << endl;

   // Input two characters:
   cin >> ac;
   cin >> bc;

   // Cast chars to uint8_t so that ISO-8859-1 characters will
   // always be > ASCII characters, even on systems which use
   // a signed "char" type:
   a = static_cast<uint8_t>(ac);
   b = static_cast<uint8_t>(bc);

   // Compare characters and print results:
   if (a < b)
      cout << "a < b" << endl;
   if (a == b)
      cout << "a == b" << endl;
   if (a > b)
      cout << "a > b" << endl;

   uint8_t Bob = static_cast<uint8_t>(-47);
   cout << static_cast<int16_t>(Bob) << endl;
   
   return 0;
}