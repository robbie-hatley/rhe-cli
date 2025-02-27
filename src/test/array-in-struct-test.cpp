#include <iostream>

using std::cout;
using std::endl;

struct Test
{
   int x[5];
};

int main()
{
   Test t1;
   for(int i=0; i<5; ++i)
   {
      t1.x[i]=i;
      cout << "t1.x element " << i << " = " << t1.x[i] << endl;
   }

   Test t2(t1);
   
   for(int i=0; i<5; ++i)
   {
      t2.x[i]=i+5;
      cout << "t2.x element " << i << " = " << t2.x[i] << endl;
   }

   for(int i=0; i<5; ++i)
   {
      cout << "t1.x element " << i << " = " << t1.x[i] << endl;
   }

   return 0;
}
