#include <iostream>
#include <fstream>
#include <string>
#include <cstdlib>
#include <cstring>
using namespace std;
struct myWeather
{
wchar_t *cityName;
float *temperature, *pressure, *direction, *wind;
myWeather *next, *prev;
};
myWeather *readData();
int main()
{
myWeather *location, *currLoc;
location = readData();
currLoc = location;
for(int c=0; c<49; c++)
{
cout<< "temp value"<< c+1<<": "<< (*currLoc->temperature+c)<<endl;
}
for(int f=0; f<1441; f++)
{
cout<< "pressure value"<< f+1<<": "<< *(currLoc->pressure+f)<<endl;
}
for(int g=0; g<720; g++)
{
cout<< "Dir value"<< g+1<<": "<< *(currLoc->direction+g)<<endl;
}
for(int h=0; h<720; h++)
{
cout<< "Wind value"<< h+1<<": "<< *(currLoc->wind+h)<<endl;
}
return 0;
}
myWeather *readData()
{
myWeather *headPTR;
char cityText[80];
wchar_t cityNym[80];
string myCity;
float tmpData[49], prsData[1441], winData[720], dirData[720];
int len;
ifstream weatherFile ("Data.txt", ios::in);
headPTR = new myWeather;
getline(weatherFile, myCity);
len= myCity.length();
myCity.copy(cityText, len, 0);
cityText[len]='\0';
mbstowcs(cityNym, cityText, strlen(cityText)+1);
headPTR->cityName = new wchar_t;
headPTR->cityName= cityNym;
weatherFile>> cityText;
weatherFile>>len;
for(int a=0; a<49; a++)
{
weatherFile>>tmpData[a];
}
headPTR->temperature = new float;
headPTR->temperature = tmpData;
weatherFile>> cityText;
weatherFile>>len;
for(int b=0; b<1441;b++)
{
weatherFile>>prsData[b];
}
headPTR->pressure= new float;
headPTR->pressure= prsData;
weatherFile>> cityText;
weatherFile>>len;
for(int d=0; d<720; d++)
{
weatherFile>>dirData[d];
}
headPTR->wind= new float;
headPTR->wind= dirData;
weatherFile>> cityText;
weatherFile>>len;
for(int e=0; e<720; e++)
{
weatherFile>>winData[e];
}
headPTR->direction = new float;
headPTR->direction = winData;
weatherFile.close();
return headPTR;
}[code]