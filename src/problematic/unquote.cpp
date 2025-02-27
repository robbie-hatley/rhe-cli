/****************************************************************************\
 * unquote.cpp
 * Removes those annoying "> "s from beginning of quoted lines.
 * I began writing this...  2001?  2002?  2003?
 * I did further work on it 2005-08-10.
 * Still unfinished.
 *
 *
 *
\****************************************************************************/

using namespace std;

#include <iostream>
#include <fstream>
#include <list>

#include "rhutil.hpp"
#include "rhdir.hpp"

void Help(void);

int main(int Felix, char *Poindexter[])
{
   if (rhutil::HelpDecider(Felix, Poindexter, Help)) return 777;
   std::string FileName = std::string(Poindexter[1]);
   std::list<std::string> Text;

   std::cout << "STUBB!!!" << endl;

   ifstream Fred;
   Fred.open(FileName.c_str());
   if (!Fred)
   {
      std::cerr << "Can't open file" << std::endl;
      exit(666);
   }
   std::string Buffer;
   while(Felix)
   {
      std::getline(Fred, Buffer);
      if (Fred.eof()) break;
      Text.push_back(Buffer);
   }
   std::list<std::string>::iterator i;
   for (i = Text.begin(); i != Text.end(); ++i)
   {
      std::cout << (*i) << std::endl;
   }

   std::cout << "STUBB!!!" << endl;

   return 0;
}

void Help(void)
{
   std::cout << "Will (eventually) remove > marks from start of lines." << std::endl;
   std::cout << "STILL AN EXTREME STUBB!" << std::endl;
   return;
}

