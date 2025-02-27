// add-test.c
#include <stdio.h>
#include <stdlib.h>
int main(int Beren, char * Luthien[])
{
   double a = 0;
	double b = 0;
	double c = 0;
	if (3 != Beren) {exit(EXIT_FAILURE);}
   a = strtod(Luthien[1], NULL);
   b = strtod(Luthien[2], NULL);
	c = a + b;
	printf("%f + %f = %f\n", a, b, c);
   exit(EXIT_SUCCESS);
}
