/****************************************************************************\
 * test-bed.cpp
 * No telling what this program is about at any one time!  
 * It serves as a test bed to test programming ideas.  
 * Just paste-in your code below, and let 'r rip!
\****************************************************************************/

#include <iostream>
#include <list>
#include <string>

#include "rhutil.hpp"
#include "rhmath.hpp"
#include "rhdir.hpp"

namespace ns_Test
{
   using std::cin;
   using std::cout;
   using std::cerr;
   using std::endl;
   
   void PrintFileInfo(rhdir::FileRecord const & File);
}

int main(void)
{
   using namespace ns_Test;
   std::list<rhdir::FileRecord> Files;
   rhdir::LoadFileList(Files);
   for_each(Files.begin(), Files.end(), ns_Test::PrintFileInfo);
   return 0;
}

void 
ns_Test::
PrintFileInfo
   (
      rhdir::FileRecord const & File
   )
{
   cout 
      << "File Record:      " << File                       << endl
      << "File TimeString:  " << rhdir::GetTimeString(File) << endl
                                                            << endl;
   return;
}
