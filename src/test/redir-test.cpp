
#include <iostream>

int main (void)
{
   using std::cout;
   using std::cerr;
   using std::endl;

   std::ios_base::sync_with_stdio();

   cout << "1st line of text on stdout." << endl;
   cerr << "1st line of text on stderr." << endl;
   cout << "2nd line of text on stdout." << endl;
   cerr << "2nd line of text on stderr." << endl;
   cout << "3rd line of text on stdout." << endl;
   cerr << "3rd line of text on stderr." << endl;

   return 0;
}
