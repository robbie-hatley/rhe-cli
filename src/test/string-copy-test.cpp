// string-copy-test.cpp

#include <iostream>
#include <string>
#include <vector>

int main (void)
{
   std::vector<std::string> Strings = 
   {
      "slfjhwucy",
      "dkghwudsh",
      "eibnxcsgf",
      "qmsndvzxf",
      "aodjgbcrw",
      "xifhseqnv",
      "aoeudgfrs",
      "soqeixmfs",
      "jcbmtzdqb"
   };
   char CharMatrix[9][9];
   int i,j;
   for ( i = 0 ; i < 9 ; ++i ) // for each string
   {
      for ( j = 0 ; j < 9 ; ++j ) // for each char
      {
         CharMatrix[i][j]=Strings[i][j];
      }
   }
   // Now lets print that back to make sure it worked:
   for ( i = 0 ; i < 9 ; ++i ) // for each string
   {
      for ( j = 0 ; j < 9 ; ++j ) // for each char
      {
         std::cout << CharMatrix[i][j];
      }
      std::cout << std::endl;
   }
   return 0;   
}
