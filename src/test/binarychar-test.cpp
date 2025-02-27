/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * binarychar.cpp
 * A program which shows the bits of a signed char.
 * Written Tuesday July 24, 2001 by Robbie Hatley
 * Last updated Saturday May 10, 2003.
 * Input:  Single signed-char command-line argument (-128 to 127).
 * Output: Binary representation of input.
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <cstring>
#include <cctype>
#include <cmath>

using std::cout;
using std::endl;
using std::cerr;

struct Bits
{
  unsigned int bit0 : 1;
  unsigned int bit1 : 1;
  unsigned int bit2 : 1;
  unsigned int bit3 : 1;
  unsigned int bit4 : 1;
  unsigned int bit5 : 1;
  unsigned int bit6 : 1;
  unsigned int bit7 : 1;
};

union Bitfield
{
  char chr;
  Bits bits;
};

int main(int argc, char *argv[])
{
  long int input = atol(argv[1]);
  if (input < -128 or input > 127)
  {
    cerr 
      << "Sorry, binarychar takes an input between -128 and 127 inclusive."
      << endl;
    exit(1);
  }
  Bitfield n;
  n.chr = (char) input;
  cout << "Signed char " << (int)n.chr << " in binary = "
       << n.bits.bit7
       << n.bits.bit6
       << n.bits.bit5
       << n.bits.bit4
       << n.bits.bit3
       << n.bits.bit2
       << n.bits.bit1
       << n.bits.bit0
       << endl;
  return 0;
}
