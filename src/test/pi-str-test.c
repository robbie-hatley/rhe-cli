// pi-str-test.c
#include <math.h>
#include <stdio.h>
int main (void)
{
	long double pi_Lf      =  3.14159265358979323846264338327950288419716939937510582097494l;
	double      pi_f       =  3.14159265358979323846264338327950288419716939937510582097494 ;
	char        pistr[256] = "3.14159265358979323846264338327950288419716939937510582097494";
	printf("pi string = %70s\n"     , pistr);
	printf("pi lngdbl = %71.60Lf\n" , pi_Lf);
	printf("pi double = %71.60f\n"  , pi_f);
	return 0;
}