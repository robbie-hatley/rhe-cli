#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <new>
#include <cstring>
#include <cmath>

using namespace std;

int main(int argc, char**argv)
{
  char *sometext=new char[75];
  strcpy(sometext, "This is some text.");
  cout << sometext << endl;
  delete[] sometext;
  char * apointer = new char; // (atoi(argv[1]));
  cout << ( (int) (*apointer) ) << endl;
  delete apointer;
  return 0;
}


