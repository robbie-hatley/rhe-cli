/************************************************************************************************************\
 * Program name:  Meta Test 01
 * Description:   Calculates N^M
 * File name:     meta-test-01.cpp
 * Source for:    meta-test-01.exe
 * Author:        Robbie Hatley
 * Date written:  Monday Jun 19, 2006
 * Inputs:        Two command-line arguments, M and N which must be integers.
 * Outputs:       M^N to stdout
 * Notes:         Mostly a test of template metaprogramming.
\************************************************************************************************************/

#include <iostream>

template<int M, int N>
class Pow
{
   public:
      enum {Result = M * Pow<M, N-1>::Result};
};

template<int M>
class Pow<M, 0>
{
   public:
      enum {Result = 1};
};

int main()
{
   std::cout << Pow<8, 3>::Result << std::endl;
   return 0;
}
