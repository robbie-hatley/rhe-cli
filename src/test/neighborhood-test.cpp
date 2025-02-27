#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cctype>
#include <cmath>
#include <ctime>

#include <iostream>
#include <vector>
#include <string>
#include <new>
#include <utility>

#include "rhutil.hpp"
#include "rhmath.hpp"
#include "rhbitmap.hpp"

double Func(double x, double y) {return 3.2*x*x - 7.3*y + 4.6;}

int main(void)
{
   using std::cout;
   using std::endl;
   double x, y;
   rhmath::Neighborhood n (3.8, 5.2, 22.7, 22.7, 5);
   for (int j=0; j<5; ++j)
   {
      for (int i=0; i<5; ++i)
      {
         x = n.get_preimage(i, j).first;
         y = n.get_preimage(i, j).second;
         cout << endl;
         cout << "Preimage[" << j << "][" << i << "] = (" << x << ", " << y << ")" << endl;
         cout << "Image[" << j << "][" << i << "] = " << n.get_image(i,j) << endl;
      }
   }
   cout << endl << endl;
   cout << "Now transforming...." << endl;
   n.transform(Func);
   for (int j=0; j<5; ++j)
   {
      for (int i=0; i<5; ++i)
      {
         x = n.get_preimage(i, j).first;
         y = n.get_preimage(i, j).second;
         cout << endl;
         cout << "Preimage[" << j << "][" << i << "] = (" << x << ", " << y << ")" << endl;
         cout << "Image[" << j << "][" << i << "] = " << n.get_image(i,j) << endl;
      }
   }
   cout << "minimum = " << n.minimum() << endl;
   cout << "maximum = " << n.maximum() << endl;
   cout << "average = " << n.average() << endl;
   return 0;
}
