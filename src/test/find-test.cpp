/****************************************************************************\
 * Project name:  FindTest
 * File name:     
 * Module Title:  
 * Author:        Robbie Hatley
 * Date written:  
 * Last edited:   
 * Description:   
 * Inputs:        
 * Outputs:       
 * Notes:         
 * To make:       
\****************************************************************************/

/****************************************************************************\
 *                  PREPROCESSOR DIRECTIVES:                                *
\****************************************************************************/

// Include old C headers:
#include <cstdlib>
#include <cstring>
#include <cctype>

// Include new C++ headers:
#include <iostream>
#include <iomanip>
#include <list>
#include <string>
#include <typeinfo>

// Include personal class-library headers:
#include "rhmath.hpp"
#include "rhutil.hpp"

/****************************************************************************\
 *                  DECLARATIONS:                                           *
\****************************************************************************/

using std::cout;
using std::endl;
using std::string;


/****************************************************************************\
 *                  MAIN:                                                   *
\****************************************************************************/

int main(int argc, char *argv[])
{
  string Blat ("Nebekenezer was Auswitz-bound with Karl Marx from his site under a pale aardvark sky.");
  cout << Blat.rfind("siaarlandishness"+3, string::npos, 2) << endl;
  return 0;
}

/****************************************************************************\
 *                  FUNCTION DEFINTIONS:                                    *
\****************************************************************************/

// Put definitions of all functions here.
