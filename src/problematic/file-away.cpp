/************************************************************************************************************\
 * Program name:  File-Away
 * Description:   Stores files in alphabetical and numerical directories.
 * File name:     file-away.cpp
 * Source for:    file-away.exe
 * Author:        Robbie Hatley
 * Date written:  Thu Aug 25, 2005
 * Inputs:        None
 * Outputs:       None
 * To make:       Link with rhutil.o and rhdir.o in librh.a
 * Edit History:
 *   Thu Aug 25, 2005 - Wrote it.
 *   Thu Sep 15, 2005 - Simplified it a bit.
 *   Sun Mar 29, 2009 - Wrote help.
\************************************************************************************************************/

#include <cctype>

#include <iostream>
#include <iomanip>
#include <fstream>
#include <list>
#include <string>
#include <algorithm>

#include <unistd.h>
#include <dir.h>

#include "rhutil.hpp"
#include "rhdir.hpp"

namespace ns_FileAway
{
   using std::cin;
   using std::cout;
   using std::cerr;
   using std::endl;

   bool CheckDirs(void);
   void FileAway(void);
   void FileFile(rhdir::FileRecord const & F);

   void Help(void);
}

int main(int Beren, char* Luthien[])
{
   using namespace ns_FileAway;
   if (rhutil::HelpDecider(Beren, Luthien, Help)) return 777;
   if (!CheckDirs())
   {
      cerr << "Error: missing director(y)(ies)." << endl;
      exit(567);
   }
   FileAway();
   return 0;
}



bool
ns_FileAway::
CheckDirs
   (
      void
   )
{
   std::list<std::string> StdDirNames;
   StdDirNames.push_back("!#$%@_");
   StdDirNames.push_back("0");
   StdDirNames.push_back("1");
   StdDirNames.push_back("2");
   StdDirNames.push_back("3");
   StdDirNames.push_back("4");
   StdDirNames.push_back("5");
   StdDirNames.push_back("6");
   StdDirNames.push_back("7");
   StdDirNames.push_back("8");
   StdDirNames.push_back("9");
   StdDirNames.push_back("a");
   StdDirNames.push_back("b");
   StdDirNames.push_back("c");
   StdDirNames.push_back("d");
   StdDirNames.push_back("e");
   StdDirNames.push_back("f");
   StdDirNames.push_back("g");
   StdDirNames.push_back("h");
   StdDirNames.push_back("i");
   StdDirNames.push_back("j");
   StdDirNames.push_back("k");
   StdDirNames.push_back("l");
   StdDirNames.push_back("m");
   StdDirNames.push_back("n");
   StdDirNames.push_back("o");
   StdDirNames.push_back("p");
   StdDirNames.push_back("q");
   StdDirNames.push_back("r");
   StdDirNames.push_back("s");
   StdDirNames.push_back("t");
   StdDirNames.push_back("u");
   StdDirNames.push_back("v");
   StdDirNames.push_back("w");
   StdDirNames.push_back("x");
   StdDirNames.push_back("y");
   StdDirNames.push_back("z");

   std::list<rhdir::FileRecord> Dirs;
   LoadFileList(Dirs, "*.*", 2);

   std::list<std::string> DirNames;

   for (std::list<rhdir::FileRecord>::iterator i = Dirs.begin(); i != Dirs.end(); ++i)
   {
      DirNames.push_back(i->name);
   }

   for(std::list<std::string>::iterator i = StdDirNames.begin(); i != StdDirNames.end(); ++i)
   {
      if (DirNames.end() == find(DirNames.begin(), DirNames.end(), (*i)))
      {
         return false;
      }
   }

   return true;
}



void
ns_FileAway::
FileAway
   (
      void
   )
{
   std::list<rhdir::FileRecord> Files;
   rhdir::LoadFileList(Files);
   for_each(Files.begin(), Files.end(), FileFile);
   return;
}



void
ns_FileAway::
FileFile
   (
      rhdir::FileRecord const & F
   )
{
   std::string OldFileName = F.name;
   std::string NewFileName = F.name;
   char Key = tolower(OldFileName[0]);
   if (isalpha(Key) || isdigit(Key))
   {
      NewFileName = Key + std::string("/") + OldFileName;
   }
   else
   {
      NewFileName = std::string("!#$%@_") + std::string("/") + OldFileName;
   }
   if (!__file_exists(OldFileName.c_str()))
   {
      cerr
      << "Error in ns_FileAway::FileFile: no file with name " << endl
      << OldFileName << " exists!  Continuing with next file." << endl;
      return;
   }
   if (__file_exists(NewFileName.c_str()))
   {
      cerr
      << "Error in ns_FileAway::FileFile: file with name " << endl
      << NewFileName << " already exits!  Continuing with next file." << endl;
      return;
   }
   if (rhdir::FileNameIsInvalid(OldFileName))
   {
      cerr
      << "Error in ns_FileAway::FileFile: old file name " << endl
      << OldFileName << " is invalid!  Continuing with next file." << endl;
      return;
   }
   cout << "Now renaming " << OldFileName << " to " << NewFileName << endl;
   int ReturnValue = _rename(OldFileName.c_str(), NewFileName.c_str());
   if (0 != ReturnValue)
   {
      cerr
      << endl
      << "Error in file-away.exe, in function ns_FileAway::FileFile():" << endl
      << "_rename() failed to perform the following rename:"            << endl
      << "Old file name: " << OldFileName                               << endl
      << "New file name: " << NewFileName                               << endl
      << "Calling abort() to prevent (further?) destruction of files."  << endl
      << endl;
      abort();
   }

   return;
}



void
ns_FileAway::
Help
   (
      void
   )
{
   cout
   << "file-away files-away your files in alpha-numeric directories," << endl
   << "if they exist.  (If they don't, it does nothing.)"             << endl
   << "An alpha-numeric directory set may be created with alphdirs."  << endl;
   return;
}
