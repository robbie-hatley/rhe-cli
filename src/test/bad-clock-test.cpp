#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <time.h>
using std::cout;using std::endl;int main(void){time_t qkdb;
time(&qkdb);struct tm dncy;dncy = *localtime(&qkdb);
char kfhc[51];for (int i=0;i<51;++i) kfhc[i]='\0';
strftime(kfhc,50,"%I:%M%p, %A %B %d, %Y\n",&dncy);
std::string bifw = kfhc;cout << bifw << endl;return 0;}