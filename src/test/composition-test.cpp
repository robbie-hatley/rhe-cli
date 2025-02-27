/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * composition.cpp
 * A test of composition in C++ (compare to nested-classes.cpp)
 * Written Wednesday August 1, 2001 by Robbie Hatley
 * Creates classes, all at the global level, of varying degrees of
 * specificity: population, person, organ, cell; then composes a population
 * from the bottom up:
 * - a cell (class) is made of protoplasm 
 * - an organ (class) is made of cells (objects)
 * - a person (class) is made of organs (objects)
 * - a population (class) is made of persons (objects)
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <cstdlib>
#include <iostream>
#include <cstring>

/*
 * Define Classes, starting from the bottom and composing upward:
 */ 

class cell {
  public:
    cell() {strcpy(contents, "protoplasm");}
    void madeof(void) {cout << contents;}
  private:
    char contents[20];
};

class organ {
  public:
    cell cells[10];
};

class person {
  public:
    organ organs[10];
};

class population {
  public:
    person persons[10];
};

int main(int argc, char *argv[])
{
  population Los_Angeles;
  cout << "cell 2 of organ 5 of person 3 in L.A. is made of ";
  Los_Angeles.persons[3].organs[5].cells[2].madeof();
  cout << ".\n\n";
  cell randomcell;
  cout << "A random cell is made of ";
  randomcell.madeof();
  cout << ".\n\n";
  return 0;
}

/*
 * Notes: it seems to me that composition is much more useful than
 * nested classes (compare nested-classes.cpp).  Since all the classes are
 * defined globally, they are all accessible directly from main() or other
 * functions.
 */


