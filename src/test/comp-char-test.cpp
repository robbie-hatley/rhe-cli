// comp-char-test.cpp
#include <iostream>
#include <string>
#include <cstdint>
using std::cin;
using std::cout;
using std::endl;
using std::flush;
using std::string;
using std::getline;
int main (void) {
   string  st = ""   ; // string   ab
   char    ca = '\0' ; // char     a
   char    cb = '\0' ; // char     b
   int16_t ia = 0    ; // integer  a
   int16_t ib = 0    ; // integer  b
   int16_t df = 0    ; // integer  ib-ia

   // Prompt user to input two characters:
   cout << "Type two characters then hit enter:" << endl;
   getline(cin, st);
   cout << "st now contains " << st.length() << " characters." << endl;
   cout << "st = " << st << endl;

   // Get characters from string:
   ca = st.c_str()[0];
   cb = st.c_str()[1];
   cout << "ca = " << ca << endl;
   cout << "cb = " << cb << endl;

   // Get the integer versions of ca and ca:
   ia = static_cast<int16_t>(static_cast<uint8_t>(ca));
   ib = static_cast<int16_t>(static_cast<uint8_t>(cb));

   // Compute difference ib-ia:
   df = ib - ia;

   // Compare characters and print results:
   if (ia <  ib) {cout << "a <  b" << endl;}
   if (ia == ib) {cout << "a == b" << endl;}
   if (ia >  ib) {cout << "a >  b" << endl;}
   cout << "ia = " << ia << endl;
   cout << "ib = " << ib << endl;
   cout << "df = " << df << endl;
   return 0;
}
