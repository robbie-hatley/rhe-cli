// satyajeet-test-2.cpp
#include <iostream>
#include <vector>
#include <string>
using namespace std;
class Person
{
   public:
      int Number;
      string Field1;
      string Field2;
      string Date;
      char Active;
};

int main(void)
{
   //Person Peeps []; // How are you going to avoid overrun???
   Person Peeps [50];
   Peeps[0] = {    3323,"abc","zzz","27/07/2012", 'y'};
   Peeps[1] = {     332,"bcd","xyz","26/07/2012", 'y'};
   Peeps[2] = {   33332,"efg","def","29/07/2011", 'y'};
   Peeps[3] = { 3332332,"klm","nop","28/09/2013", 'n'};
   cout << "Date for person 3 = " << Peeps[2].Date << endl;
   cout << "Is person 4 active? " << Peeps[3].Active << endl;
   return 0;
}
