/************************************************************************************************************\
 * File name:     poker.cpp
 * Source for:    poker.exe
 * Program name:  Poker
 * Description:   Calculates and totals probability of all ranks of poker hands.
 * Author:        Robbie Hatley
 * Date written:  Sunday July 18, 2004
 * Last edited:   Sunday July 18, 2004
\************************************************************************************************************/

#include <cstdlib>
#include <cstring>
#include <cctype>
#include <cmath>

#include <iostream>
#include <map>

#include "rhmath.hpp"

namespace MyNameSpace 
{
   using std::cin;
   using std::cout;
   using std::cerr;
   using std::endl;
   using std::string;
   using std::map;
   
   using namespace rhmath;
   
   enum Hands
   {
      StraightFlush,
      FourOfAKind,
      FullHouse,
      Flush,
      Straight,
      ThreeOfAKind,
      Pair,
      NoPair
   };
}

int main()
{
   using namespace MyNameSpace;
   double back = (double)Comb(52, 5);
   return 0;
}
