#include<iostream>
#include<list>
#include<string>
int main (void)
{
   std::list<std::string> Bob;                 // empty list
   std::list<std::string>::iterator i;         // iterator for list

   for ( i=Bob.begin() ; i!=Bob.end() ; ++i )  // Test "i!=Bob.end()" will fail.
   {
      std::cout << (*i) << std::endl;          // This will never be executed.
   }

   Bob.push_back("Sam");
   Bob.push_back("Tom");

   for ( i=Bob.begin() ; i!=Bob.end() ; ++i )  // Test "i!=Bob.end()" will succeed.
   {
      std::cout << (*i) << std::endl;          // This will execute twice.
   }

   return 0;
}
