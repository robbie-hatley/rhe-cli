// bell.c
#include <stdio.h>
#include <curses.h>
#include <rhncgraphics.h>
int main(void)
{
   EnterCurses();
   beep();
   ExitCurses();
   return 0;
}