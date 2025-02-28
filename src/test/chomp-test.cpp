#include <iostream>
using std::cout; using std::endl;
typedef double Crunch(int, char);
void Bite(Crunch Munch) {cout << Munch(7, 5) << endl;};
double Chomp(int a, char b) {return static_cast<double>(a*b);}
int main()
{
   Bite(Chomp);
   return 0;
}
