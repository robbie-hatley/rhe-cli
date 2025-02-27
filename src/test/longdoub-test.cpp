/****************************************************************************\
 * Long Double Test
 *
 *
 *
 *
 *
 *
\****************************************************************************/

using namespace std;

#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <cstring>
#include <cctype>
#include <cmath>
#include <ctime>
#include <new>

int main(int argc, char *argv[])
{
  ios::sync_with_stdio();
  long double var1, var2;
  var1=9876543210.123451234512345L;
  printf("%Lf\n", var1);
  var1=4225000000.1L;
  var2=sqrt(var1);
  printf("%Lf\n", var2);
  return 0;
}

