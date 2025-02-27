
// length-limit-test.c

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

// Does a given string represent an integer?
bool IsInt (char * String)
{
   size_t    i;
   size_t    n;
   unsigned  ASCII;

   // 0th character may be a digit or a minus sign;
   // if it's neither, return false:
   ASCII = (unsigned)String[0];
   if ( (ASCII<48 || ASCII>57) && (ASCII != 45) )
      return false;

   // The remaining characters must be digits:
   n = strlen(String);
   for ( i = 1 ; i < n ; ++i )
   {
      ASCII = (unsigned)String[i];
      if (ASCII<48 || ASCII>57)
      {
         return false;
      }
   }

   // If we get to here, String represents an integer, so return true:
   return true;
}

int main (void)
{
   char     *   Line   = NULL;
   size_t       Size   = 0;
   ssize_t      Read   = 0;
   bool         Quit   = false;
   long         Numb   = 0;

   while (!Quit)
   {
      // Print message:
      printf("Type a positive integer, 5 digits max (or type \"quit\" to exit):\n");

      // We're about to use getline in unallocated mode.
      // But if Line is not NULL here, then it points to allocated space 
      // from a previous iteration of this loop, which would cause a
      // segmentation fault. So if Line is non-NULL here, free it and NULL it:
      if (Line)
      {
         free(Line);
         Line = NULL;
      }

      // Get input:
      Read = getline(&Line, &Size, stdin);

      // Abort if read failed:
      if (-1 == Read)
      {
         printf("Error: Read failure.\n");
         exit(666);
      }

      // Get rid of the newline:
      if (strlen(Line) >= 1 && '\n' == Line[strlen(Line)-1])
      {
         Line[strlen(Line)-1]='\0';
         --Read;
      }

      // Complain and loop if user typed empty string:
      if (Read < 1)
      {
         printf("You typed an empty message! Try again.\n");
         continue;
      }

      // Does user want to quit?
      if (0 == strcmp(Line, "quit"))
      {
         Quit = true;
         continue;
      }

      // If user typed something non-numeric, complain and loop:
      if (!IsInt(Line))
      {
         printf("That wasn't a number! Try again.\n");
         continue;
      }

      // If we get here, user typed a positive integer, so let's convert
      // its string representation into a "long" data type:
      Numb = strtol(Line, NULL, 10);

      // If the number is not in-range (positive integer, 5-digits max),
      // then complain and loop:

      if (Numb < 0)
      {
         printf("Negative numbers are not allowed! Try again.\n");
         continue;
      }

      if (Numb == 0)
      {
         printf("Zero is not allowed! Try again.\n");
         continue;
      }

      if (Numb > 99999)
      {
         printf("Number over 5 digits are not allowed! Try again.\n");
         continue;
      }

      // If we get to here, user typed 1-to-5-digit positive integer,
      // so print it and loop:
      printf("Congratulations! You typed %ld ! Here, have a cookie! @ \n", Numb);
   }

   // De-allocate anything we allocated:
   if (Line)
   {
      free(Line);
      Line = NULL;
   }
   
   // We're done, so scram:
   return 0;
}