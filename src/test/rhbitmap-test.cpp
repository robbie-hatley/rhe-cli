// test-rhbitmap.cpp

#include <iostream>
#include <iomanip>

using std::cout;
using std::endl;

#include "test-rhbitmap.hpp"

rhbitmap::Color::Color(const int& r, const int& g, const int& b) {
  blue=b;
  green=g;
  red=r;
  dummy=0;
}
