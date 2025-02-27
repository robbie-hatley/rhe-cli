// Aluwani-Corrected.cpp
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

using namespace std;

struct myWeather
{
   wchar_t         cityName[80];
   vector<double>  temperature;
   vector<double>  pressure;
   vector<double>  direction;
   vector<double>  wind;
};

void readData (myWeather & MW)
{
   // Declare variables:
   char cityText[80];
   string myCity;
   size_t len;             // length of string
   size_t i;               // general iterator

   // Open data file:
   ifstream weatherFile ("Data.txt", ios::in);

   // Get first line of text and store in auto std::string "myCity":
   getline (weatherFile, myCity);

   // Store length of myCity in "len":
   len = myCity.length();

   // Copy text from std::string myCity to C string cityText:
   myCity.copy (cityText, len, 0);

   // Add-in nul terminator:
   cityText[len] = '\0';

   // Convert from mbs to wcs and store:
   mbstowcs (MW.cityName, cityText, strlen (cityText) + 1);

   // Get and ignore some data from file:
   weatherFile >> cityText;
   weatherFile >> len;

   // Get and store temperature data:
   for ( i = 0 ; i < 49 ; ++i )
   {
      weatherFile >> MW.temperature[i];
   }

   // Get and ignore some data from file:
   weatherFile >> cityText;
   weatherFile >> len;

   // Get and store pressure data:
   for ( i = 0 ; i < 1441 ; ++i )
   {
      weatherFile >> MW.pressure[i];
   }

   // Get and ignore some data from file:
   weatherFile >> cityText;
   weatherFile >> len;

   // Get and store wind direction data:
   for ( i = 0 ; i < 720 ; ++i )
   {
      weatherFile >> MW.direction[i];
   }

   // Get and ignore some data from file:
   weatherFile >> cityText;
   weatherFile >> len;

   // Get and store wind speed data:
   for ( i = 0 ; i < 720 ; ++i )
   {
      weatherFile >> MW.wind[i];
   }
   weatherFile.close ();
   return;
}

int main (void)
{
   // Declare automatic (TEMPORARY, LOCAL) variables:
   int         i;            // general iterator for "for" loops
   myWeather   MW;           // weather-data object

   // Read data from file into weather-data object:
   readData(MW);

   // Print data from weather-data object:

   for ( i = 0 ; i < 49 ; ++i )
   {
      cout << "temperature[" << i << "] = " << (MW.temperature[i]) << endl;
   }

   for ( i = 0; i < 1441; ++i )
   {
      cout << "pressure[" << i << "] = " << (MW.pressure[i]) << endl;
   }

   for ( i = 0 ; i < 720 ; ++i )
   {
      cout << "direction[" << i << "] = " << (MW.direction[i]) << endl;
   }

   for ( i = 0 ; i < 720 ; ++i )
   {
      cout << "wind[" << i << "] = " << (MW.wind[i]) << endl;
   }

   return 0;
}
