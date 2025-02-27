// closure-test.cpp
#include <iostream>
#include <vector>
#include <string>
using namespace std;
vector<int> & DataRepository (void);
int main(void)
{
   vector<int> & vref = DataRepository();
   unsigned long i;
   cout << "Original contents:" << endl;
   for ( i = 0 ; i < vref.size() ; ++i ) {cout << vref[i] << " ";}
   cout << endl;
   for ( i = 0 ; i < vref.size() ; ++i ) {vref[i]/=2;}
   cout << "Final contents:" << endl;
   for ( i = 0 ; i < vref.size() ; ++i ) {cout << vref[i] << " ";}
   cout << endl;
   return 0;
}

vector<int> & DataRepository (void)
{
   static vector<int> v = {82, 135, 94, 111, 163};
   return v;
}
