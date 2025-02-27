/****************************************************************************\
 * corner-test.c
 * Prints random cusswords all over the screen.
 * Written Tue. June 07, 2005 by Robbie Hatley.
 * Edit history:
 *   Jun 07, 2005: Wrote it.
 *   Feb 22, 2018: Updated. Changed from DJGPP & DOS to Cygwin & Ncurses.
\****************************************************************************/

#include "rhncgraphics.h"
#include "rhutilc.h"

// MAIN:
int main(void)
{
   int c;
   EnterCurses();
   WriteChar('A', 0,          0,         NCC_RED_BLACK);
   WriteChar('B', 0,          Width - 1, NCC_RED_BLACK);
   WriteChar('C', Height - 1, Width - 1, NCC_RED_BLACK);
   WriteChar('D', Height - 1, 0,         NCC_RED_BLACK);
   
   while (1)
   {
      c = getch();
      if ('q' == (char)c) break;
      Delay(0.2);
   }
   ExitCurses();
   return 0;
} // end main()
