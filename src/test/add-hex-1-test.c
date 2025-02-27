// add-hex-1-test.c
#include <stdio.h>
#include <stdint.h>
int main (void)
{
   uint32_t x  = 0x1223344; // x is now 0x1223344
            x += 0x0002200; // x is now 0x1225544
   printf("0x%X\n", x);
   return 0;
}