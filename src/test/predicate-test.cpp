#include <vector>
#include <algorithm>

using namespace std;

struct A
{
    int a;
    A(int a0): a(a0) {}
};

bool comp (const A& a1, const A& a2)
{
   return a1.a<a2.a;
}

double comp (int a, char b)
{
   return a + b;
}

int main(void)
{
    vector<A> a;
    a.push_back(A(4));
    a.push_back(A(7));
    sort( a.begin(), a.end(), comp );

    return 0;
}
