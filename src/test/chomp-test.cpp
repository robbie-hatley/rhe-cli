#include <iostream>
typedef double Crunch(int, char);
void Bite(Crunch Munch) {std::cout << Munch(7, 5);};
double Chomp(int a, char b) {return (double)(a*b);}
int main() 
{
   Bite(Chomp);
   return 0;
}
