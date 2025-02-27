#include <cstdlib>
int main (void) {
   system("perl -E 'say map {\"$_\\n\"} 1..100'");
}
