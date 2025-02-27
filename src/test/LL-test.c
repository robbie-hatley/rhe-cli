/*
LL-test.c
*/

#include <stdio.h>
#include <stdlib.h>
#include "rhdefines.h"

int main (void)
{
   long Fred = 0;
   printf("size of Fred: %lu\n", sizeof(Fred));
   printf("size of char:               %lu\n",sizeof(char));
   printf("size of unsigned char:      %lu\n",sizeof(unsigned char));
   printf("size of short:              %lu\n",sizeof(short));
   printf("size of unsigned short:     %lu\n",sizeof(unsigned short));
   printf("size of int:                %lu\n",sizeof(int));
   printf("size of unsigned int:       %lu\n",sizeof(unsigned int));
   printf("size of long:               %lu\n",sizeof(long));
   printf("size of unsigned long:      %lu\n",sizeof(unsigned long));
   printf("size of UL:                 %lu\n",sizeof(UL));
   printf("size of long long:          %lu\n",sizeof(long long));
   printf("size of LL:                 %lu\n",sizeof(LL));
   printf("size of unsigned long long: %lu\n",sizeof(unsigned long long));
   printf("size of ULL:                %lu\n",sizeof(ULL));
   for ( Fred = 0LL ; Fred <= 1000000LL ; Fred += 100000LL )
   {
      printf("Fred = %20ld  Fred*Fred = %20ld\n", Fred, Fred*Fred);
   }
   return 0;
}
