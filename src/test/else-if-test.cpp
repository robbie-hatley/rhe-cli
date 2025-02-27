#include <iostream>
using std::cin;
using std::cout;
using std::endl;
int main()
{
   int age;
   std::cout<<"Please tell me your age: \n\n";
   cin >> age;
   cin.ignore();
   if (age < 50)
   {
      cout << "... spring chicken ..." << endl;
   }
   else // age is 50 or more
   {
      if ( age >= 50 && age <70)
      {
         cout << "... lay off the beer ..." << endl;
      }
      else // age is 70 or more
      {
         if ( age >= 70 && age < 100)
         {
            cout << "... twilight ..." << endl;
         }
         else // age is 100 or more
         {
            cout << "... Daaamn Methuselah! ..." << endl;
         }
      }
   }
   return 0;
}

