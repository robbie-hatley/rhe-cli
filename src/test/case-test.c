// case-test.c

#include <stdio.h>

void MaIn (void)
{
   printf("In MaIn().\n");
   return;
}

void mAiN (void)
{
   printf("In mAiN().\n");
   return;
}

int main (void)
{
   MaIn();
   mAiN();
   printf("In main().\n");
   return 0;
}