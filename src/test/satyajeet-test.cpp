// satyajeet-test.cpp
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
   vector<Person> Peeps;
   Peeps.push_back({3323,"abc","zzz","27/07/2012", 'y'});
   Peeps.push_back({332,"bcd","xyz","26/07/2012", 'y'});
   Peeps.push_back({33332,"efg","def","29/07/2011", 'y'});
   Peeps.push_back({3332332,"klm","nop","28/09/2013", 'n'});
   cout << "Date for person 3 = " << Peeps[2].Date << endl;
   cout << "Is person 4 active? " << Peeps[3].Active << endl;
   return 0;
}
