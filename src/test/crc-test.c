#include <stdio.h>

int main (void)
{
   unsigned char bytes [5] = {0x13, 0xA7, 0x02, 0xF5, 0x94};
   unsigned char CRC;
   int i;
   for ( i = 0 , CRC = 0x00 ; i < 5 ; ++i )
   {
      CRC ^= bytes[i];
   }
   printf("CRC = %X", CRC);
   return 0;
}
