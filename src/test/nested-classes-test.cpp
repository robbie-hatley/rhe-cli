
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * nested-classes.cpp
 * A test of nested classes in C++
 * Written Wednesday August 1, 2001 by Robbie Hatley
 * Last updated 8-6-2001
 * Creates a class with several levels of nesting, and tests the features
 * of this bizarre but fascinating concept.
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <cstring>
#include <cctype>
#include <cmath>
#include <ctime>
#include <new>

using namespace std;

class person {
  public:
    person(char *moniker) {strcpy(name, moniker);}
    char name[78];
    int age() {return years;}
    void age(int y) {years=y;}
    class organ {
      public:
        class cell {
          public:
            cell() {strcpy(contents, "protoplasm");}
            void madeof(void) {cout << contents;}
            static void third1(void) {cout << "Third Level Static Function!\n";}
            void third2(void) {cout << "Third Level Non-Static Function!\n";}
            void cancer(person per) {cout << per.name << " has cancer!\n";}
          private:
            char contents[20];
        };
        cell acell;
    };
    organ aorgan;
  private:
    int years;
    organ heart;
    organ liver;
    organ brain;
};

int main(int argc, char *argv[])
{
  ios::sync_with_stdio();
  person bob ("Bob");
  bob.age(42);
  cout << "Bob's age is " << bob.age() << " and Bob's cells are made of ";
  bob.aorgan.acell.madeof();
  cout << ".\n";
  person::organ::cell::third1();   //static function called by nesting
  bob.aorgan.acell.third2();       //nonstatic function called by composition
  person::organ::cell cancer_cell; //data type called by nesting
  cancer_cell.cancer(bob);         //member function applied to object
  return 0;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * Conclusion: A class declared inside a class is NOT a member of the
 * enclosing class. Consequently, if class B is nested in class A, then
 * "A.B" is a parse error, because B is not a member of A.  Putting class B
 * inside class A merely tells the compiler that the scope of class B is
 * is restricted to within class A.  This scope restriction can be
 * circumvented with the scope operator "::".  Hence "A::B" means  
 * "the data type defined by class B, whose scope is normally restricted
 * to within class A".  Hence the primary usefulness of a nested class is
 * to define a data type whose scope is limited to within the enclosing
 * class.  Static members of nested classes, however, may be accessed by
 * any function by using "::".  Example: given class A which contains
 * class B which contains class C which has a static member function D(),
 * then D() may be accessed with "A::B::C::D()".  This sytax for nested
 * classes mirrors the syntax for nested objects: "a.b.c.d()".
 * -Robbie Hatley, 8-6-2001 
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
