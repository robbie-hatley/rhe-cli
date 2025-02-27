// nested-function-call-test.c
#include <stdio.h>
double Square (double a) {return a*a;} // a basic square function
double AddSeven (double a) {return a+7.0;} // just adds 7
double Linear (double a) {return AddSeven(Square(a));} // note nested function call
int main (void) {double a = 32.7; printf("%f\n",Linear(a));return 0;} // note nested function call