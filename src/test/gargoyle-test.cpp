#include <iostream>
#include <vector>

struct Gargoyle
{
   Gargoyle(char a, int b) : actor(a), eger(b) {}
   char  actor;
   int   eger;
};

int main()
{
   std::vector<Gargoyle*> Fizzbin;
   Fizzbin.push_back(new Gargoyle('a', 97));
   Fizzbin.push_back(new Gargoyle('b', 98));
   Fizzbin.push_back(new Gargoyle('c', 99));

   // ... a bunch of code ...
   // ... use elements of Fizzbin somehow ...
   // ... a bunch more code ...

   // Clear Fizzbin:
   std::vector<Gargoyle*>::iterator i;
   for (i = Fizzbin.begin() ; i != Fizzbin.end() ; )
   {
      std::cout << (*i)->actor << "  " << (*i)->eger << std::endl;
      delete (*i);          // delete object at location (*i)
      i = Fizzbin.erase(i); // delete pointer from vector
   }
   return 0;
}
