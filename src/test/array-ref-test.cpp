// arrayref-test.cpp
#include<iostream>
int main (void)
{
   int arr[10]={32,98,17,84,66,73,21,36,43,87};
   int (&ref)[10]=arr;
   std::cout << ref[5] << std::endl;
   return 0;
}
