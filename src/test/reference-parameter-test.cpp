// reference-parameter-test.cpp
#include <iostream>
using namespace std;

// NON-CONST REF; FUNCTION ALTERS ITS ARGUMENT:
void AlterInPlace (double & Tom) // "Tom" is alias to argument
{
   Tom = 1.8631 * Tom - 7.6492;
}

// CONST REF; FUNCTION DOESN'T ALTER ITS ARGUMENT:
double ReturnAltered (double const & Sue) // "Sue" can't be altered
{
   return 2.9175 * Sue - 8.3476;
}

// VALUE; FUNCTION DOESN'T ALTER ITS ARGUMENT:
double Triple (double Input) // "Sue" can't be altered
{
   return 3.0 * Input;
}

int main (void)
{
   double Fred = 473.8659;
   cout << "Unaltered version of Fred = " << Fred  << endl;
   AlterInPlace(Fred);
   cout << "Altered   version of Fred = " << Fred  << endl;
   double Janet = ReturnAltered(Fred);
   cout << "Altered    copy   of Fred = " << Janet << endl;
   cout << "Original   copy   of Fred = " << Fred  << endl;
   double Sue = Triple(Fred);
   cout << "Triple of  copy   of Fred = " << Sue   << endl;
   return 0;
}