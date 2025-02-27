#include <iostream>
using namespace std;
int main (void)
{
   int Fred = 0x03020100;
   unsigned char * BytePtr = (unsigned char *)&Fred;
   printf("First  byte = %d\n", (int)*BytePtr);
   ++BytePtr;
   printf("Second byte = %d\n", (int)*BytePtr);
   ++BytePtr;
   printf("Third  byte = %d\n", (int)*BytePtr);
   ++BytePtr;
   printf("Fourth byte = %d\n", (int)*BytePtr);
   return 0;
}
