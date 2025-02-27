

/************************************************************************************************************\
 * Program name:  Prefix Test
 * Description:   Tests personal library Prefix(), Suffix(), DeMultiply().
 * File name:     prefix-test.cpp
 * Source for:    prefix-test.exe
 * Author:        Robbie Hatley
 * Date written:  Wed Aug 10, 2005
 * To make:       Link with rhdir.o
 * Edit History:  Wed Aug 10, 2005 - Wrote it.
\************************************************************************************************************/

#include <iostream>
#include <string>
#include <list>

#include "rhdir.hpp"

namespace ns_PrefixTest
{
   using std::cin;
   using std::cout;
   using std::cerr;
   using std::endl;
   using std::string;
   using std::list;
}


// ============= Function Definitions: =======================================================================

/************************************************************************************************************\
 * main():                                                                                                  *
\************************************************************************************************************/

int main(void)
{
   using namespace ns_PrefixTest;
   string Name = string("");
   
   Name = string("Agamemnon.mice.txt");
   cout 
      << "Raw name:   " << Name                << endl
      << "Prefix:     " << rhdir::Prefix(Name) << endl
      << "Suffix:     " << rhdir::Suffix(Name) << endl
      << endl
      << endl;
   
   Name = string("AgamemnonMiceTxt");
   cout 
      << "Raw name:   " << Name                << endl
      << "Prefix:     " << rhdir::Prefix(Name) << endl
      << "Suffix:     " << rhdir::Suffix(Name) << endl
      << endl
      << endl;

   return 0;
}
