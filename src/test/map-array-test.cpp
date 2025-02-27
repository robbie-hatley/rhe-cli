#include <iostream>
#include <string>
#include <map>
#include <utility>

using std::cout;
using std::endl;
using std::string;
using std::map;
using std::pair;
using std::make_pair;

// Commenting-out things to simplify for test:
class Files
{
   public:
   //   void nextFile(string*, string*);
   //   void open(vector<string>*, int);

   //private:
   //   int getNumber(string); // Gets the number from the filename

      map<int, string[2]> fileSets;
      //map<int, string[2]>::iterator iter;
};


int main(void)
{
   Files MyFiles;
   pair<string,string> Splat = make_pair<string,string>("apple", "peach");
   MyFiles.fileSets.insert(make_pair<int, pair<string,string> >(37, Splat));
   
   cout 
      << "Map element 37 first  string = " 
      << MyFiles.fileSets[37].first  
      << endl;
   
   cout 
      << "Map element 37 second string = " 
      << MyFiles.fileSets[37].second 
      << endl;
   
   return 0;
}

