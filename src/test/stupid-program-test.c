#include <stdio.h>
int i = 0;
void a (void) {printf("%4d",++i);if(0==i%10){printf("\n");}}
void b (void) {a();a();a();a();a();a();a();a();a();a();}
void c (void) {b();b();b();b();b();b();b();b();b();b();}
int  main (void) {c();return 0;}
