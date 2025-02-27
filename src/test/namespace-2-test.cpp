// file2.cpp
#include<iostream>
using std::cout;
namespace MyNiftyNameSpace
{
   void fun();
   void show(){
      fun();
      cout<<"show called\n";
   }
}

