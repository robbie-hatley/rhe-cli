/****************************************************************************\
 *template-test.cpp
 *
 *
 *
 *
 *
 *
\****************************************************************************/

#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <cstring>
#include <cctype>
#include <cmath>
#include <ctime>
#include <new>

using namespace std;


template<typename blat>
class asdf {
  public:
    void set(blat x) {qwer=x;}
    blat get(void) {return qwer;}
  private:
    blat qwer;
};


int main(int argc, char *argv[])
{
  ios::sync_with_stdio();
  asdf<char>   ob_ch;
  asdf<double> ob_db;
  ob_ch.set('t');
  ob_db.set(37.2974);
  cout<<"ob_ch = "<<ob_ch.get()<<endl;
  cout<<"ob_db = "<<ob_db.get()<<endl;
  return 0;
}

