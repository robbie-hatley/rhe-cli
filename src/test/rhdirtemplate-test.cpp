

/************************************************************************************************************\
 * File name:     rhdirtemplatetest.cpp
 * Source for:    rhdirtemplatetest.exe
 * Author:        Robbie Hatley
 * Date written:  Saturday June 26, 2004
 * Last edited:   Saturday June 26, 2004
 * Notes:         Tests templates in rhdir
 * To make:       Link with rhdir.o in librh.a
\************************************************************************************************************/

#include <iostream>
#include <vector>
#include <deque>
#include <list>
#include <map>

#include "rhdir.hpp"

using std::cout;
using std::endl;
using std::vector;
using std::deque;
using std::list;
using std::multimap;

using rhdir::FileRecord;
using rhdir::DirRecord;

int main(void)
{
   // ===== VECTOR FILE TEST =====
   {
      cout << "BEGINNING VECTOR FILE TEST:" << endl;
      vector<FileRecord> BlatV;
      LoadFileList(BlatV);
      vector<FileRecord>::iterator i;
      for (i = BlatV.begin(); i != BlatV.end(); ++i) cout << (*i) << endl;
      cout << endl << endl;
   }
   
   // ===== VECTOR DIRECTORY TEST =====
   {
      cout << "BEGINNING VECTOR DIRECTORY TEST:" << endl;
      vector<DirRecord> BlatV;
      LoadDirList(BlatV);
      vector<DirRecord>::iterator i;
      for (i = BlatV.begin(); i != BlatV.end(); ++i) cout << (*i) << endl;
      cout << endl << endl;
   }
   
   // ===== DEQUE FILE TEST =====
   {
      cout << "BEGINNING DEQUE FILE TEST:" << endl;
      deque<FileRecord> BlatV;
      LoadFileList(BlatV);
      deque<FileRecord>::iterator i;
      for (i = BlatV.begin(); i != BlatV.end(); ++i) cout << (*i) << endl;
      cout << endl << endl;
   }
   
   // ===== DEQUE DIRECTORY TEST =====
   {
      cout << "BEGINNING DEQUE DIRECTORY TEST:" << endl;
      deque<DirRecord> BlatV;
      LoadDirList(BlatV);
      deque<DirRecord>::iterator i;
      for (i = BlatV.begin(); i != BlatV.end(); ++i) cout << (*i) << endl;
      cout << endl << endl;
   }
   
   // ===== LIST FILE TEST =====
   {
      cout << "BEGINNING LIST FILE TEST:" << endl;
      list<FileRecord> BlatV;
      LoadFileList(BlatV);
      list<FileRecord>::iterator i;
      for (i = BlatV.begin(); i != BlatV.end(); ++i) cout << (*i) << endl;
      cout << endl << endl;
   }
   
   // ===== LIST DIRECTORY TEST =====
   {
      cout << "BEGINNING LIST DIRECTORY TEST:" << endl;
      list<DirRecord> BlatV;
      LoadDirList(BlatV);
      list<DirRecord>::iterator i;
      for (i = BlatV.begin(); i != BlatV.end(); ++i) cout << (*i) << endl;
      cout << endl << endl;
   }
   
   // ===== MAP FILE TEST =====
   {
      cout << "BEGINNING MAP FILE TEST:" << endl;
      multimap<size_t, FileRecord> BlatV;
      LoadFileMap(BlatV);
      multimap<size_t, FileRecord>::iterator i;
      for (i = BlatV.begin(); i != BlatV.end(); ++i) cout << ((*i).second) << endl;
      cout << endl << endl;
   }
   
   return 0;
}
