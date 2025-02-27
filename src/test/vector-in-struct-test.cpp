// vector-in-struct-test.cpp

#include <iostream>
#include <vector>

using std::vector;

struct MyStruct
{
   int a;
   vector<int> b;
};

int main(void)
{
   using std::cout;
   using std::endl;
   
   // InitSize is initial size of container of objects:
   const int InitSize = 10;
   
   vector<MyStruct> Objs (InitSize);
   
   { // Limit scope
      MyStruct Splat; // Temporary object
      Splat.a = 13;
      Splat.b.push_back(22);
      Splat.b.push_back(10);
      Objs[0] = Splat;
   } // Splat is uncreated here
   
   { // Limit scope
      MyStruct Splat; // Temporary object
      Splat.a = 97;
      Splat.b.push_back(33);
      Splat.b.push_back(84);
      Splat.b.push_back(27);
      Objs[1] = Splat;
   } // Splat is uncreated here
   
   vector<MyStruct>::size_type i; // Index to Objs
   vector<int>::iterator j;       // Iterator to elements of b
   
   for (i = 0; i <2; ++i)
   {
      cout << "Object Number: " << i << endl;
      cout << "Value of a:    " << Objs[i].a << endl;
      cout << "Elements of b:" << endl;
      for (j = Objs[i].b.begin(); j != Objs[i].b.end(); ++j)
      {
         cout << (*j) << endl;
      }
      cout << endl << endl;
   }
   return 0;
}
