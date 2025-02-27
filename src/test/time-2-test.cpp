#include <iostream>
#include <iomanip>
#include <string>
#include <sstream>
#include <ctime>

int main (void)
{
   time_t Time = std::time(NULL);
   std::cout << "Time = " << Time << std::endl;
   struct tm * TimeFields = std::localtime(&Time);
   std::cout << "year = " << TimeFields->tm_year << std::endl;
   return 0;
}
