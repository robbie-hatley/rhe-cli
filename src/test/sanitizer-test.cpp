// To compile: g++ -O -g -fsanitize=address heap-use-after-free.cc
int main(int argc, char **argv) {
  int *array = new int[100];
  delete [] array;
  return array[argc];  // BOOM
}
