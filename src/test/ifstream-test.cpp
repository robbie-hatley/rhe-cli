#include <iostream>
#include <fstream>
#include <string>

using std::cin;
using std::cout;
using std::cerr;
using std::endl;

int main(int, char* Sam[]) 
{
  std::string s;
  std::ifstream ins;
  ins.open(Sam[1]);
  if (!ins)
  {
    cerr << "Can't open file." << endl;
    return 1;
  }
  bool flag = false;
  while (42)
  {
    getline(ins, s);
    if (ins.bad())
    {
       flag = true;
       cerr << "Stream is bad!" << endl;
    }
    if (ins.fail())
    {
       flag = true;
       cerr << "Stream has failed!" << endl;
    }
    if (ins.eof())
    {
       flag = true;
       cerr << "Stream is eof!" << endl;
    }
    if (flag) break;
    cout << s << endl;
  }
  ins.close();
  return 0;
}
