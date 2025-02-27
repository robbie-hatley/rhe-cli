/************************************************************************************************************\
 * Program name:  erase_ph
 * Description:   Erases "*_ph.jpg" files if corresponding "*_fs.jpg" files exist.
 * File name:     erase_ph.cpp
 * Source for:    erase_ph.exe
 * Author:        Robbie Hatley
 * Date written:  Monday June 19, 2006
\************************************************************************************************************/

// Use asserts?
#undef NDEBUG
//#define NDEBUG
#include <assert.h>

#include <iostream>
#include <list>
#include <string>
#include <algorithm>
#include <functional>

#include "rhutil.hpp"
#include "rhdir.hpp"

namespace ns_Eph
{
   using std::cin;
   using std::cout;
   using std::cerr;
   using std::endl;

   typedef std::list<std::string>            LS;
   typedef std::list<std::string>::iterator  LSI;

   void erase_ph(void);
   void Help(void);
}


int main(int Nelix, char* Felix[])
{
   using namespace ns_Eph;

   if (rhutil::HelpDecider(Nelix, Felix, Help)) return 777;

   rhdir::RecursionDecider (Nelix, Felix, erase_ph);

   return 0;
}


void
ns_Eph::
erase_ph
   (
      void
   )
{
   LS Ph;
   rhdir::LoadFileList(Ph, "*_ph.jpg");

   LSI i;
   std::string Small, FullSize;
   std::string::size_type Index;
   for (i = Ph.begin(); i != Ph.end(); ++i)
   {
      Small     = *i;
      FullSize  = Small;
      Index = FullSize.find("_ph.jpg");
      assert(std::string::npos != Index);
      FullSize.replace(Index, 3, "_fs");
      if (rhdir::FileExists(FullSize))
      {
         rhutil::PrintString("Removing file " + Small);
         remove(Small.c_str());
      }
   }

   return;
}


void
ns_Eph::
Help
   (
      void
   )
{
   rhutil::PrintString
   (
      "Welcome to erase_ph, Robbie Hatley's nifty program for deleting small-sized\n"
      "(*_ph.jpg) Webshots.com pictures if the full-size versions (*_fs.jpg)\n"
      "already exist in the same directory.\n\n"
      "Usage:\n"
      "   erase_ph [-h|--help]   (get help)\n"
      "   erase_ph               (erase all *_ph.jpg for which *_fs.jpg exist)\n"
   );
}

// end file erase_ph.cpp
