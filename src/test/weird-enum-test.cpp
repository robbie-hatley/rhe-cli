// weird-enum-test.cpp
#include <iostream>

enum Blat {asdf, qwer, yuio, ghjk};

class eicoq
{
  public:
    eicoq(Blat aa) : a(aa) {}
    Blat geta() {return a;}
    void seta(Blat vbnm) {a=vbnm; return;}
  private:
    Blat a;
};

int main()
{
   eicoq qpfjt (qwer);
   qpfjt.seta(yuio);
   Blat jam = qpfjt.geta();
   std::cout << jam << std::endl;
   return 0;
}
