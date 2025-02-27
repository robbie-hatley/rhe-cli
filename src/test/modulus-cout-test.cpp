#include <iostream>
using namespace std;
int main()
{
   int d = 24; 
   int m = 10; 
   int y = 2940; 
   int c = 0; 
   int val;
   val = (d + m + y + (y/4) + c) % 7; 
   cout << val; 
   return 0;
}
