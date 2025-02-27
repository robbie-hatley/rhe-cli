/************************************************************************************************************\
 * Program name:  ProcessWWW
 * Description:   Processes raw####.txt files in "F:\Principal\Resources\WWW".  Generates
 *                urls####.txt, links####.html, and pics####.html files.
 * File name:     processwww.cpp
 * Source for:    processwww.exe
 * Author:        Robbie Hatley
 * Date written:  Saturday June 17, 2006
 * Inputs:        Reads raw####.txt files.  No command-line inputs.
 * Outputs:       Outputs corresponding urls####.txt, pics####.html, and links####.html files.
 * Edit History:
 *   Sun Apr 15, 2007:
 *     Renamed from "ProcessLBR" to "ProcessWWW".  Changed from using the LBR folder to using the WWW folder.
 *     Changed to new file naming and numbering system, using 4-digit numbers.  Now looks for files named
 *     raw####.txt, processes them to extract URLs, and generates files urls####.txt, pics####.html, and
 *     pics####.html.
 *   Thu Sep 18, 2008:
 *     Changed drive from "H" to "F", and changed folder from "Principal's Office" to "Principal".
 *
\************************************************************************************************************/

#include <iostream>
#include <list>
#include <string>

#include "rhutil.hpp"
#include "rhdir.hpp"


namespace ns_ProcessWWW
{
   using std::cin;
   using std::cout;
   using std::cerr;
   using std::endl;

   typedef std::list<std::string>            LS;
   typedef std::list<std::string>::iterator  LSI;

   void  ProcessWWW   (void);
   void  ProcessFile  (std::string RawFile);
   void  Help         (void);
}


int main(int Eger, char* Actor[])
{
   using namespace ns_ProcessWWW;
   std::ios_base::sync_with_stdio();
   if (rhutil::HelpDecider(Eger, Actor, Help)) return 777;
   ns_ProcessWWW::ProcessWWW();
   return 0;
}


void
ns_ProcessWWW::
ProcessWWW
   (
      void
   )
{
   // Go to drive F:
   system ("F:");

   // Go to WWW
   bool Error = rhdir::GoToDir("/Principal/Resources/WWW");

   if (Error) return;

   // Note: I backslash the question marks in the two LoadFileList calls below
   // to prevent any possibility of the proprocessor or compiler misinterpretting
   // them as parts of triglyphs or conditional operators.

   LS RawFiles;
   rhdir::LoadFileList(RawFiles, "raw\?\?\?\?.txt");

   LS PrcFiles;
   rhdir::LoadFileList(PrcFiles, "urls\?\?\?\?.txt");

   std::string RawFile, PrcFile;
   LSI i, j;
   for (i = RawFiles.begin(); i != RawFiles.end(); ++i)
   {
      RawFile = *i;
      PrcFile = RawFile;                          // Start with "raw####.txt".
      PrcFile.replace(0, 3, "urls");              // change "raw" to "urls".
      if                                          // If found processed version,
         (
            PrcFiles.end()
            !=
            find
            (
               PrcFiles.begin(),
               PrcFiles.end(),
               PrcFile
            )
         )
      {
         cout << "File " << PrcFile << " already exists." << endl;
         continue;                                // skip to next file.
      }
      else                                        // Otherwise,
      {
         cout << "File " << PrcFile << " does NOT exist; making urls, pics, and links files." << endl;
         ProcessFile(RawFile);                    // process raw file.
      }
   }

   return;
}


void
ns_ProcessWWW::
ProcessFile
   (
      std::string RawFile
   )
{
   std::string NumStr = RawFile.substr(3,4);

   std::string UrlFile = "urls"  + NumStr + ".txt"  ;
   std::string PixFile = "pics"  + NumStr + ".html" ;
   std::string LnxFile = "links" + NumStr + ".html" ;

   std::string Cmd1 =
      "awk -f E:\\Scripts\\extract-urls.awk       < " + RawFile + " | sortdup > " + UrlFile;
   std::string Cmd2 =
      "awk -f E:\\Scripts\\present-jpg-images.awk < " + UrlFile +      " > "      + PixFile;
   std::string Cmd3 =
      "awk -f E:\\Scripts\\present-urls.awk       < " + UrlFile +      " > "      + LnxFile;

   system(Cmd1.c_str());
   system(Cmd2.c_str());
   system(Cmd3.c_str());
   return;
}


void
ns_ProcessWWW::
Help
   (
      void
   )
{
   rhutil::PrintString
   (
      "This program, processwww, processes any not-yet-processed raw####.txt\n"
      "files, creating urls####.txt, pics####.html, and links####.html.\n"
   );
   return;
}


// end file processwww.cpp
