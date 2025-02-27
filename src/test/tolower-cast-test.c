#include <stdio.h>
#include <ctype.h>
#include <locale.h>

int main (void)
{
   setlocale (LC_ALL, "en_US.ISO-8859-1");
   char InpChar1 = (char)65;
   int  Lowered1 = tolower(InpChar1);
   char OutChar1 = Lowered1;
   
   char InpChar2 = (char)192;
   int  Lowered2 = tolower(InpChar2);
   char OutChar2 = Lowered2;

   printf( "InpChar1 = %c (%d)\n", InpChar1, (int)InpChar1 );
   printf( "Lowered1 = %d     \n", Lowered1                );
   printf( "OutChar1 = %c (%d)\n", OutChar1, (int)OutChar1 );
   printf( "\n"                                            );
   printf( "InpChar2 = %c (%d)\n", InpChar2, (int)InpChar2 );
   printf( "Lowered2 = %d     \n", Lowered2                );
   printf( "OutChar2 = %c (%d)\n", OutChar2, (int)OutChar2 );
   printf( "\n"                                            );
   printf( "isalpha((char) 65) = %d\n", isalpha((char) 65) );
   printf( "isalpha((char)192) = %d\n", isalpha((char)192) );
   
   return 0;
}
