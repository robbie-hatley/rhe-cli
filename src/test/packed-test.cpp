#include <stdio.h>

struct Packed
{
   char Able     __attribute__ ((packed));
   char Baker    __attribute__ ((packed));
   char Charlie  __attribute__ ((packed));
};

struct Unpacked
{
   char Able;
   char Baker;
   char Charlie;
};

int main(void)
{
   struct Packed    packed;
   struct Unpacked  unpacked;
   
   printf("Size of  packed  struct: %li\n", sizeof(packed));
   printf("Size of unpacked struct: %li\n", sizeof(unpacked));
   return 0;
}
