/****************************************************************************\
 * color-size-test.cpp
\****************************************************************************/

#include <iostream>
#include "rhbitmap.hpp"

using std::cout; using std::endl;

rhbitmap::Color blat (201, 98, 137);

int main(void) {
   cout << sizeof(blat) << endl;
   return 0;
}
