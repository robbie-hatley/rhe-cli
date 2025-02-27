#include <set>
#include <algorithm>
#include <list>

class myInt
{
   int i_;
public:
   myInt() : i_(0) {}
   myInt(int i): i_(i) {}
   int val() const { return i_; }
   void setVal(int i) { i_ = i; }
   bool operator<(const myInt & rhs) const { return i_ < rhs.i_; }
};

struct intAdder
{
   int Right;
   intAdder(int R) : Right(R) {}
   void operator()(myInt & Left) {Left.setVal(Left.val() + Right);}
};


int main()
{
   std::set<myInt> s;

   s.insert( myInt( 3 ) );
   s.insert( myInt( 5 ) );

   std::for_each(s.begin(), s.end(), intAdder(2));

   return 0;
}
