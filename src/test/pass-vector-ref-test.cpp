// pass-vector-ref-test.cpp
#include <iostream>
#include <vector>
#include <string>
using namespace std;
void CutInHalf (vector<int> & v);
int main(void)
{
   unsigned long i;
   vector<int> Vec = {82, 135, 94, 111, 163};
   cout << "Original contents:" << endl;
   for ( i = 0 ; i < Vec.size() ; ++i ) {cout << Vec[i] << " ";}
   cout << endl;
   CutInHalf(Vec);
   cout << "Final contents:" << endl;
   for ( i = 0 ; i < Vec.size() ; ++i ) {cout << Vec[i] << " ";}
   cout << endl;
   return 0;
}

void CutInHalf (vector<int> & v)
{
   unsigned long i;
   for ( i = 0 ; i < v.size() ; ++i ) {v[i]/=2;}
   return;
}
