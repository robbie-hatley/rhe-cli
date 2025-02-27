#include <set>
int main(void)
{
   std::set<int> s;
   s.insert( 3 );
   s.insert( 5 );
   *(s.begin()) = 9;
   return 0;
}
