// file1.cpp
#include<iostream>
using std::cout;
namespace MyNiftyNameSpace
{
   void show();
   void fun() {cout << "fun called\n";}
}

int main()
{
   MyNiftyNameSpace::show();
   return 0;
}


