#include <iostream>
#include <cstdlib>
#include <cmath>
#include <ctime>

using namespace std;

void Randomize(void) {
  srand(time(0));
}

double RandNum(double min, double max) {
  return min+(max-min)*((double)rand()/(double)RAND_MAX);
}

int RandInt(int min, int max) {
  return min+int(floor(RandNum(min+0.01, max+0.99)));
}

int main(int argc, char** argv) {
  int a = atoi(argv[1]);           // first arg is lower limit
  int b = atoi(argv[2]);           // second arg is upper limit
  Randomize();                     // randomize seed
  for (int i=1; i<=10; ++i) {      // loop 10 times
    cout << RandInt(a, b) << endl; // random integer between a and b
  }
  return 0;
}
