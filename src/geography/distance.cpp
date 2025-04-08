// This is a 79-character-wide utf-8-encoded C++ source-code text file.  
// ¡Hablo Español!  Говорю Русский.  Björt skjöldur.  麦藁雪、富士川町、山梨県。  
//=======|=========|=========|=========|=========|=========|=========|=========

// distance.cpp

#include <cmath>
#include <iostream>

using namespace std;
double lat1,lon1,lat2,lon2;	
double radius = 6371.0;
double pi = 3.1415926535897;

double dtr(double deg)
{
   return (deg*pi/180);
}

double ed(double lat1d, double lon1d, double lat2d, double lon2d)
{
    double lat1r,lon1r,lat2r,lon2r,A;
    
    //CONVERT DEGREES TO RADIANS
    lat1r = dtr(lat1d);
    lon1r = dtr(lon1d);
    lat2r = dtr(lat2d);
    lon2r = dtr(lon2d);
    
    //COORDINATE DIFFERENCES
    A = lon2r - lon1r;
    
    //RETURN DISTANCE
    return (180.0/pi) * acos(sin(lat1r)*sin(lat2r)+cos(lat1r)*cos(lat2r)*cos(A));
}

int main() {

	//OBTAIN COORDINATES FROM USER
		cout << "ENTER LATITUDE OF START POINT: ";
		cin >> lat1;

		cout << "ENTER LONGITUDE OF START POINT: ";
		cin >> lon1;

		cout << "ENTER LATITUDE OF DESTINATION: ";
		cin >> lat2;

		cout << "ENTER LONGITUDE OF DESTINATION: ";
		cin >> lon2;
		cout << "\n";

	//OUTPUT DISTANCE
	cout << "arclength between coordinates: " << ed(lat1, lon1, lat2, lon2) << " degrees."<< endl;

return 0;
}
