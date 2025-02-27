#include <stdio.h>
int main (int Fred, char * Ethel[])
{
   char InputChar;
   if (Fred >= 2) {InputChar = Ethel[1][0];}
   else {return 666;}
   switch (InputChar)
   {
      case 'A':
         printf("Argument is A.\n");
         goto DEFAULT;
      case 'B':
         printf("Argument is B.\n");
         goto DEFAULT;
      case 'C':
         printf("Argument is C.\n");
         goto DEFAULT;
      DEFAULT:
      default:
         printf("Always print this.");
   }
   return 0;
}
      