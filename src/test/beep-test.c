// beep-test.c
#include <stdio.h>
#include <windows.h>
int main(void)
{
   Beep(1000,1000);
   Beep(1500, 500);
   Beep(1250, 500);
   Beep(1300, 500);
   Beep(1150, 500);
   return 0;
}