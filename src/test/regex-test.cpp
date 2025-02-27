/************************************************************************************************************\
 * Program name:  (this line for stand-alone programs only)
 * Module name:   (this line for library modules only)
 * Description:   
 * File name:     
 * Header for:    (this line for headers only)
 * Source for:    (this line for source files only)
 * Author:        Robbie Hatley
 * Date written:  
 * Inputs:        
 * Outputs:       
 * Notes:         
 * To make:       
 * Edit History:
 *    
\************************************************************************************************************/

#include <iostream>
#include <string>

#include <sys/types.h>
#include <regex.h>

#include "rhutil.hpp"

int main(int Tom, char* Jerry[])
{
   using std::cout;
   using std::endl;
   
   if (Tom < 3) return 5;
   std::string Pattern = std::string(Jerry[1]);
   std::string Text    = std::string(Jerry[2]);
   
   regmatch_t Matches[10];
   
   int iResult = rhutil::RegEx(Pattern, Text, Matches);
   
   cout << "Result code from rhutil::RegEx = " << iResult << endl;
   cout << "Matches[0].rm_so = " << Matches[0].rm_so << endl;
   cout << "Matches[0].rm_eo = " << Matches[0].rm_eo << endl;
   if (REG_OKAY != iResult) return 0;
   cout << Text.substr(Matches[0].rm_so, Matches[0].rm_eo - Matches[0].rm_so) << endl;
   return 0;
}
