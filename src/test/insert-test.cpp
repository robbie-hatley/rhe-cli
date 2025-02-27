#include <iostream>
#include <fstream>

using std::ios_base;
using std::cout;
using std::cerr;
using std::endl;
using std::ifstream;

int main()
{
   ifstream I ("C:\\test.txt");
   if (!I.good() || !I.is_open())
   {
      cerr << "Error: Couldn't open file!" << endl;
      exit(666);
   }
   unsigned short int a = 0;
   while (1)
   {
      I >> a;
      if (I.bad())
      {
         cerr << "Error: Input bad!" << endl;
         I.close();
         exit(666);
      }
      else if (I.eof())
      {
         cout << "End of file." << endl;
         break;
      }
      else if (I.fail())
      {
         cerr << "Error: Input fail!" << endl;
         I.close();
         exit(666);
      }
      else
      {
         cout << "Number is: " << a << endl;
      }
   }
   I.close();
   return 0;
}
