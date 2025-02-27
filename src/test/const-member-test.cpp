#include <iostream>
using std::cout; using std::endl;
class myClass
{
   public:
      myClass() : i(42), j(13) {}
      myClass(int a, int b) : i(a), j(b) {}
      myClass& operator= (myClass o) {this->j = o.j; return *this;}
      geti() {return i;}
      getj() {return j;}
   private:
      int const i;
      int       j;
};

int main()
{
	myClass a;
   myClass b (86, 74);
   cout << "Before assigning b = a :" << endl;
   cout << "a.i = " << a.geti() << endl;
   cout << "a.j = " << a.getj() << endl;
   cout << "b.i = " << b.geti() << endl;
   cout << "b.j = " << b.getj() << endl;
   b = a;
   cout << "After assigning b = a :" << endl;
   cout << "a.i = " << a.geti() << endl;
   cout << "a.j = " << a.getj() << endl;
   cout << "b.i = " << b.geti() << endl;
   cout << "b.j = " << b.getj() << endl;
}
