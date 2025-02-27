// reference-parameter-test.cpp 
#include <iostream> 
using namespace std; 

// WARNING: NON-CONST REF; FUNCTION ALTERS ITS ARGUMENT: 
void AlterInPlace (double & Tom) // "Tom" is alias to argument 
{ 
	Tom = 1.8631 * Tom - 7.6492; 
} 

// NOTE: CONST REF; FUNCTION DOESN'T ALTER ITS ARGUMENT: 
double ReturnAltered (double const & Sue) // "Sue" can't be altered 
{ 
	return 1.8631 * Sue - 7.6492; 
} 

int main (void) 
{ 
	double Fred = 473.8659; 
	cout << "Unaltered version of Fred = " << Fred << endl; 
	AlterInPlace(Fred); 
	cout << "Altered   version of Fred = " << Fred << endl; 
	double Janet = ReturnAltered(Fred); 
	cout << "Altered    copy   of Fred = " << Janet << endl; 
	cout << "Original   copy   of Fred = " << Fred << endl;       
	return 0; 
}