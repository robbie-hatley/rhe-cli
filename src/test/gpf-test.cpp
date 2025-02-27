#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <cstring>
#include <cmath>
#include <ctime>
#include <new>

using namespace std;

namespace PrimeSpace { 
  // (Variables and functions for use by PrimeDecider() and PrimeTable.)
  // Cyclic group of order 8 for use as prime-number sieve:
  const unsigned long int sieve[8]={6, 4, 2, 4, 2, 4, 6, 2};
  // Get smallest int not less than sqrt(n):
  inline unsigned long int Limit(unsigned long int n);
}

bool PrimeDecider(unsigned long int n);

class PrimeTable {
  public:
    PrimeTable(long int number_of_primes);  // parameterized constructor
    PrimeTable(PrimeTable &src);            // copy constructor
    ~PrimeTable();                          // destructor
    void operator=(PrimeTable &src);        // assignment operator
    void printprimes(void);                 // print function
  private:
    long int NumberOfPrimes;                // number of primes to store in table
    unsigned long int *primes;              // pointer to dynamic array
};

bool PrimeDecider(unsigned long int n) {
  // Returns false if n is composite, true if n is prime.
  int i;
  unsigned long int limit, d;
  if (n<2) return false;
  if (n==2||n==3||n==5) return true;
  if (!(n%2)||!(n%3)||!(n%5)) return false;
  limit=PrimeSpace::Limit(n);
  for (d=1L,i=0L; (d=d+PrimeSpace::sieve[i%8])<=limit; ++i)
    if (!(n%d)) 
      return false;
  return true;
}

PrimeTable::PrimeTable(long int number_of_primes) {
  if (number_of_primes<1 || number_of_primes>5123123) {
    cerr << "Error in PrimeTable constructor: Number of primes must be between" << endl;
    cerr << "1 and 5,123,123 inclusive." << endl;
    exit(543);
  }
  NumberOfPrimes=number_of_primes;
  int i, j;
  unsigned long int candidate;
  unsigned long int *primes;
  primes = new unsigned long int [NumberOfPrimes];
  primes[0]=2; // 2 is the 1st prime
  primes[1]=3; // 3 is the 2nd prime
  primes[2]=5; // 5 is the 3rd prime
  for (candidate=1,i=0,j=3; j<NumberOfPrimes; ++i) {  // Start search for primes.
    candidate=candidate+PrimeSpace::sieve[i%8];  // Use sieve to weed-out obvious non-primes.
    if (PrimeDecider(candidate)) {   // Is candidate prime?
      primes[j++]=candidate;         // If so, add candidate to primes[] .
      // The postfix "++" is necessary to insure that the j value used to index
      // the array is the same j value which obeyed "j<NumberOfPrimes".
      // j is incremented immediately after indexing storage of candidate in primes[],
      // so that it reflects the total number of elements in primes[] before looping 
      // back to the top of the "for" loop.
    } // end if
  } // loop back to top of "for" loop.
}

// PrimeTable copy constructor:
PrimeTable::PrimeTable(PrimeTable &src) {
  NumberOfPrimes=src.NumberOfPrimes;
  primes = new unsigned long int [NumberOfPrimes];
  int i;
  for (i=0; i<NumberOfPrimes; ++i) primes[i]=src.primes[i];
}

// PrimeTable assignment operator:
void PrimeTable::operator=(PrimeTable &src) {
  delete primes;
  NumberOfPrimes=src.NumberOfPrimes;
  primes = new unsigned long int [NumberOfPrimes];
  int i;
  for (i=0; i<NumberOfPrimes; ++i) primes[i]=src.primes[i];
}

// PrimeTable destructor:
PrimeTable::~PrimeTable() {
  delete [] primes; // free-up dynamically-allocated array
}

// PrimeTable print function:
void PrimeTable::printprimes(void) {
  long int i;
  for (i=0; i<NumberOfPrimes; ++i) {
    printf("%10lu\n", this->primes[i]);
  }
}

inline unsigned long int PrimeSpace::Limit(unsigned long int n) {
  // Return largest integer not less than the square root of the argument.
  return (unsigned long int)floor(1.0001L*sqrt((long double)n));
}

int main(void) {
  ios::sync_with_stdio();
  PrimeTable blat (100);
  blat.printprimes();
  return 0;
}
