#include <iostream>
#include <string>
#include <map>
#include <vector>
#include <utility>

using std::cout;
using std::endl;
using std::string;
using std::map;
using std::vector;
using std::pair;
using std::make_pair;

// Commenting-out things to simplify for test:
class Files
{
   public:
      void nextFile(string*, string*);
      void open(vector<string>*, int);

   //private:
      int getNumber(string); // Gets the number from the filename

      //map<int, string[2]> fileSets; // NO!!!
      
      map<int, pair<string,string> > fileSets; // YES!!!
      
      map<int, pair<string,string> >::iterator iter;
};

int main(void)
{
   Files MyFiles;
   pair<string,string> Splat;
   
   Splat = make_pair<string,string>("apple", "peach");
   MyFiles.fileSets.insert(make_pair<int, pair<string,string> >(48, Splat));
   
   Splat = make_pair<string,string>("cucumber", "dill");
   MyFiles.fileSets.insert(make_pair<int, pair<string,string> >(23, Splat));
   
   cout 
      << "Map element 23 first  string = " 
      << MyFiles.fileSets[23].first  
      << endl;
   
   cout 
      << "Map element 23 second string = " 
      << MyFiles.fileSets[23].second 
      << endl;
   
   cout 
      << "Map element 48 first  string = " 
      << MyFiles.fileSets[48].first  
      << endl;
   
   cout 
      << "Map element 48 second string = " 
      << MyFiles.fileSets[48].second 
      << endl;
   
   return 0;
}
