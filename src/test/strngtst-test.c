#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *functionName(int intParam, char *charParam);

int main(void)
{
  char *bstring; // declare a pointer to type char
  static char astring[81]; // define an array of char
  fgets(astring, 80, stdin); //get string from keyboard
  bstring=functionName(37, astring); // process string
  printf("Original string is: %s",astring);
  printf("Processed string is: %s", bstring); // print result
  return 0;
}

char *functionName(int intParam, char *charParam)
{
  // Declare a string as "static" so that it stays
  // in memory even after function exits:
  int i;
  static char newString[81];
  for (i=0; i<80; ++i)
  {
    if (charParam[i]>63)
    {
      newString[i]=charParam[i]-intParam;
    }
    else newString[i]=charParam[i];
  }
  return newString; // returns POINTER to new string
}

