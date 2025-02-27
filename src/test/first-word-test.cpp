// first-word-test.cpp
#include <iostream>
#include <string>
#include <regex>
using namespace std;
int main (int Beren, char ** Luthien)
{
   int i;
   regex  Regex ("[^a-zA-Z0-9_]*([a-zA-Z0-9_]+).*");
   smatch Results;
   for ( i = 1 ; i < Beren ; ++i )
   {
      string Input (Luthien[i]);
      regex_match (Input, Results, Regex);
      cout << Results[1] << endl;
   }
   return 0;
}

/*
Inputs and outputs:

$first-word-test '   Hello!!!  How are you??? '
Hello

$first-word-test '*&)(#dog;;:}[rabbit  ;; @'
dog
*/
