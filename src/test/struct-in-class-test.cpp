#include <iostream>
using namespace std;
struct Person
{
   int Age;
   int Height;
   int Weight;
};
class Car
{
   public:
      Person Owner;
};
int main (void)
{
   Person Bob;
   Bob.Age    =  57; // years
   Bob.Height =  68; // inches
   Bob.Weight = 328; // LB
   Car Ford;
   Ford.Owner = Bob;
   cout << "Car owner's age:    " << Ford.Owner.Age    << " years"  << endl;
   cout << "Car owner's height: " << Ford.Owner.Height << " inches" << endl;
   cout << "Car owner's weight: " << Ford.Owner.Weight << " pounds" << endl;
   return 0;
}
