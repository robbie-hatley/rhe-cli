// ListFiles.cpp

// Sun Sep 4, 2005

// This is a test to see if I can find the cause of the DOS-output-buffer truncation problem
// I've been having recently with some of my programs.


// Use asserts?
#undef NDEBUG
//#define NDEBUG
#include <assert.h>

#include <iostream>
#include <iomanip>
#include <sstream>
#include <list>
#include <string>
#include <algorithm>

#include <cstdlib>
#include <cstring>
#include <cctype>

#include <unistd.h>

#include "rhutil.hpp"
#include "rhdir.hpp"

namespace ns_A
{
   using std::cout;
   using std::cerr;
   using std::endl;
   
   void ListFiles(void);
   void inline PrintDaRecord(rhdir::FileRecord const & R);
}

int main(void)
{
   using namespace ns_A;
   ListFiles();
   return 0;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//  ListFiles()                                                                                             //
//                                                                                                          //
//  Lists Files.                                                                                            //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

void 
ns_A::
ListFiles
      (
         void
      )
{
   std::list<rhdir::FileRecord> FileList;
   rhdir::LoadFileList(FileList);
   cerr << "This is an error message.  The error is, I thought there was an error, but it turns out, "
      "I was mistaken." << endl;
   char Buffer[300];
   getcwd(Buffer,295);
   cout << "Current working directory = " << Buffer << endl;
   for_each(FileList.begin(), FileList.end(), PrintDaRecord);
   return;
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//  PrintDaRecord()                                                                                         //
//                                                                                                          //
//  Prints FileRecord objects.                                                                              //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

void 
inline 
ns_A::
PrintDaRecord
      (
         rhdir::FileRecord const & R
      )
{
   cout << R << endl;
   return;
}
