#include <iostream>
#include <iomanip>
#include <list>
#include <utility>

using std::pair;
using std::make_pair;
using std::list;
using std::cout;
using std::endl;
using std::right;
using std::setw;

bool operator&(const pair<int,int> & Left, const pair<int,int> & Right)
{
   return (Left.first < Right.first);
}

bool operator|(const pair<int,int> & Left, const pair<int,int> & Right)
{
   return (Left.second < Right.second);
}

inline void operator!(list<pair<int,int> > & Splat)
{
   Splat.sort(operator&);
}

inline void operator~(list<pair<int,int> > & Splat)
{
   Splat.sort(operator|);
}

void PrintPair(const pair<int,int> & Splat)
{
   cout << right << setw(10) << Splat.first << right << setw(10) << Splat.second << endl;
}

int main()
{
   list<pair<int, int> > Aardvark;
   
   Aardvark.push_back(make_pair<int,int>(37, 92));
   Aardvark.push_back(make_pair<int,int>(11, 82));
   Aardvark.push_back(make_pair<int,int>(84, 44));
   Aardvark.push_back(make_pair<int,int>(27, 97));
   Aardvark.push_back(make_pair<int,int>(73, 21));
   
   !Aardvark;
   
   for_each(Aardvark.begin(), Aardvark.end(), PrintPair);
   
   cout << endl << endl;
   
   ~Aardvark;
   
   for_each(Aardvark.begin(), Aardvark.end(),  PrintPair);
   
   return 0;
}
