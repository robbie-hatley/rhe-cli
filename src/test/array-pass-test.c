// array-pass-test.c
#include <stdio.h>
#include <string.h>
#define LENGTH 55
#define HEIGHT  5

// NOTE: MUST LET FUNCTION KNOW WHAT THE WIDTH OF "Array" IS,
// ELSE FUNCTION CAN'T CORRECTLY INDEX 2D ARRAY.
// (The function can operate without knowing what the height
// of "Array" is, as long as "Row" is within range, so I
// provide range-checking for "Row".)
void ReverseRow (char Array[][LENGTH], int Row)
{
   char    String[55]  = {'\0'};
   size_t  Size        = 0;
   size_t  i           = 0;

   if (Row < 0 || Row > HEIGHT-1) {return;}
   Size = strlen(Array[Row]);
   for ( i = 0 ; i < Size ; ++i )
   {
      String[i] = Array[Row][(Size-1) - i];
   }
   for ( i = 0 ; i < 55 ; ++i )
   {
      Array[Row][i] = String[i];
   }
   return;
}

int main (void)
{
   char Names[HEIGHT][LENGTH] = 
   {
      "Herbert Redman",
      "Lucy McGuire",
      "Harlan Mears",
      "Rosemary Darcey",
      "Orville Konneke"
   };
   int j = 0;

   printf("\nOriginal names:\n\n");
   for ( j = 0 ; j < HEIGHT ; ++j )
   {
      printf("%s\n", Names[j]);
   }

   for ( j = 0 ; j < HEIGHT ; ++j )
   {
      ReverseRow(Names, j);
   }

   printf("\nReversed names:\n\n");
   for ( j = 0 ; j < HEIGHT ; ++j )
   {
      printf("%s\n", Names[j]);
   }
   return 0;
}