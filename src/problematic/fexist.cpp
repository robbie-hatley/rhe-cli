#include <cstdlib>
#include <iostream>
#include <fstream>
#include <string>

using std::cout;
using std::endl;
using std::string;

bool FileExists(std::string filename);

int main(int argc, char* argv[])
{
  if (2 != argc)
     exit(666);
  string filename = argv[1];
  if (FileExists(filename))
    cout << "File exists." << endl;
  else
    cout << "No such file." << endl;
  return 0;
}

bool FileExists(std::string filename)
{
  std::ifstream ifs (filename.c_str());
  bool file_exists = ifs;
  if (ifs) ifs.close();
  return file_exists;
}
