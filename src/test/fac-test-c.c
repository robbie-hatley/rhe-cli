#include <iostream>
int main (void)                // program entry point
{
   int f = 1;                  // declare & initialize f to 1
   int i;                      // declare i
   for (i=1;i<=10;++i)         // iterate for i 1->10
   {
      f*=i;                    // multiply f by i
   }
   std::cout << "10! = " << f  // print result
   << std::endl;
   return 0;                   // exit program
}