// unique-ptr-test
#include <iostream>
#include <memory>
#include <cstdlib>

using std::cout;
using std::endl;

class Vogon
{
   public:
      Vogon(int x) : Jeltz(x) {cout << "In parameterized constructor." << endl;}
      ~Vogon()                {cout << "In destructor."                << endl;}
      void  React  () 
      {
         if (17 == Jeltz) throw 17; // Barf if 17==Jeltz
         cout << "You entered " << Jeltz
              << ".  (But don't enter \"17\"!)" << endl;
      }
      void  Poetry () {cout << "Oh, furdled gruntbuggly!" << endl;}
   private:
      int Jeltz;
};
   
int main(int Beren, char* Luthien[])
{
   if (2 != Beren) {cout << "Error: Need 1 argument." << endl; return 1;}
   int X = int(std::strtol(Luthien[1], NULL, 10));
   std::unique_ptr<Vogon> Vog (new Vogon(X));
   Vog->React();  // If user used command-line arg. "17", throw uncaught exception.
   Vog->Poetry(); // Even though the sound of it is somewhat quite atrocious.
   return 0; // Release resources???
}

