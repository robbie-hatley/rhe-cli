// stat-glob-main-test.cpp
#include <iostream>
static int Fred = 4; // static; visible in this file only
extern int Susan;    // access global variable from other file
int main(void) {
   std::cout << "Fred  = " << Fred  << std::endl
             << "Susan = " << Susan << std::endl;
   return 0;
}

