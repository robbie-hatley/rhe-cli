/* 
life.c
Plays "Conway's Game of Life".
https://en.wikipedia.org/wiki/Conway's_Game_of_Life
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>
#include <time.h>
#include <string.h>
#include <curses.h>
#include <locale.h>
#include <sys/time.h>

enum NCColor
{
   NCC_RED_BLACK          =   1,
   NCC_GREEN_BLACK        =   2,
   NCC_YELLOW_BLACK       =   3,
   NCC_BLUE_BLACK         =   4,
   NCC_MAGENTA_BLACK      =   5,
   NCC_CYAN_BLACK         =   6,
   NCC_WHITE_BLACK        =   7,
   NCC_RED_WHITE          =   8,
   NCC_GREEN_WHITE        =   9,
   NCC_YELLOW_WHITE       =  10,
   NCC_BLUE_WHITE         =  11,
   NCC_MAGENTA_WHITE      =  12,
   NCC_CYAN_WHITE         =  13,
   NCC_BLACK_WHITE        =  14,
   NCC_RED_MAGENTA        =  15,
   NCC_GREEN_MAGENTA      =  16,
   NCC_YELLOW_MAGENTA     =  17,
   NCC_BLUE_MAGENTA       =  18,
   NCC_CYAN_MAGENTA       =  19,
   NCC_WHITE_MAGENTA      =  20,
   NCC_BLACK_MAGENTA      =  21,
   NCC_RED_BLUE           =  22,
   NCC_GREEN_BLUE         =  23,
   NCC_YELLOW_BLUE        =  24,
   NCC_MAGENTA_BLUE       =  25,
   NCC_CYAN_BLUE          =  26,
   NCC_WHITE_BLUE         =  27,
   NCC_BLACK_BLUE         =  28,
   NCC_RED_CYAN           =  29,
   NCC_GREEN_CYAN         =  30,
   NCC_YELLOW_CYAN        =  31,
   NCC_MAGENTA_CYAN       =  32,
   NCC_BLUE_CYAN          =  33,
   NCC_WHITE_CYAN         =  34,
   NCC_BLACK_CYAN         =  35
};

int       NumColors            = 0;
WINDOW  * WindowHandle         = NULL;
int       Height               = 0;
int       Width                = 0;
char      Charset  [2]         = {' ', 'O'};
char      GameGrid [100][200];
char      FateGrid [100][200];

void InitColorPairs (void)
{
   init_pair(  1, COLOR_RED,     COLOR_BLACK);
   init_pair(  2, COLOR_GREEN,   COLOR_BLACK);
   init_pair(  3, COLOR_YELLOW,  COLOR_BLACK);
   init_pair(  4, COLOR_BLUE,    COLOR_BLACK);
   init_pair(  5, COLOR_MAGENTA, COLOR_BLACK);
   init_pair(  6, COLOR_CYAN,    COLOR_BLACK);
   init_pair(  7, COLOR_WHITE,   COLOR_BLACK);
   init_pair(  8, COLOR_RED,     COLOR_WHITE);
   init_pair(  9, COLOR_GREEN,   COLOR_WHITE);
   init_pair( 10, COLOR_YELLOW,  COLOR_WHITE);
   init_pair( 11, COLOR_BLUE,    COLOR_WHITE);
   init_pair( 12, COLOR_MAGENTA, COLOR_WHITE);
   init_pair( 13, COLOR_CYAN,    COLOR_WHITE);
   init_pair( 14, COLOR_BLACK,   COLOR_WHITE);
   init_pair( 15, COLOR_RED,     COLOR_MAGENTA);
   init_pair( 16, COLOR_GREEN,   COLOR_MAGENTA);
   init_pair( 17, COLOR_YELLOW,  COLOR_MAGENTA);
   init_pair( 18, COLOR_BLUE,    COLOR_MAGENTA);
   init_pair( 19, COLOR_CYAN,    COLOR_MAGENTA);
   init_pair( 20, COLOR_WHITE,   COLOR_MAGENTA);
   init_pair( 21, COLOR_BLACK,   COLOR_MAGENTA);
   init_pair( 22, COLOR_RED,     COLOR_BLUE);
   init_pair( 23, COLOR_GREEN,   COLOR_BLUE);
   init_pair( 24, COLOR_YELLOW,  COLOR_BLUE);
   init_pair( 25, COLOR_MAGENTA, COLOR_BLUE);
   init_pair( 26, COLOR_CYAN,    COLOR_BLUE);
   init_pair( 27, COLOR_WHITE,   COLOR_BLUE);
   init_pair( 28, COLOR_BLACK,   COLOR_BLUE);
   init_pair( 29, COLOR_RED,     COLOR_CYAN);
   init_pair( 30, COLOR_GREEN,   COLOR_CYAN);
   init_pair( 31, COLOR_YELLOW,  COLOR_CYAN);
   init_pair( 32, COLOR_MAGENTA, COLOR_CYAN);
   init_pair( 33, COLOR_BLUE,    COLOR_CYAN);
   init_pair( 34, COLOR_WHITE,   COLOR_CYAN);
   init_pair( 35, COLOR_BLACK,   COLOR_CYAN);
   NumColors = 35;
   return;
}

void EnterCurses (void)
{
   setlocale(LC_ALL, "");
   WindowHandle = initscr(); 
   cbreak(); 
   noecho();
   nodelay(WindowHandle, 1);
   getmaxyx(WindowHandle, Height, Width);
   start_color();
   InitColorPairs();
   attron(A_BOLD);
   clear();
   getch();
   return;
}

void ExitCurses (void)
{
   nodelay(WindowHandle, 0);
   echo();
   nocbreak();
   attroff(A_BOLD);
   endwin();
   return;
}

void WriteString (const char * String, int Row, int Column, int Color)
{
   move(Row, Column);
   do {addch((unsigned)(*String++)|COLOR_PAIR(Color));}
   while ('\0' != *String);
   return;
}

void WriteChar (char c, int Row, int Column, int Color)
{
   move(Row, Column);
   addch((unsigned)c|COLOR_PAIR(Color));
   return;
}

/* Initialize arrays: */
void InitArrays (void)
{
   memset(GameGrid, 0, 100*200*sizeof(char));
   memset(FateGrid, 0, 100*200*sizeof(char));
   return;
}

/* Initialize the game grid to all blanks: */
void InitGameGrid (void)
{
   int  i, j;
   for ( j = 0 ; j < Height ; ++j )
   {
      for ( i = 0 ; i < Width ; ++i )
      {
         GameGrid[j][i] = Charset[0];
      }
   }
   return;
}

/* Set the game grid to a fixed pattern: */
void SetGameGrid (void)
{
   if (Width < 55 || Height < 25)
   {
      fprintf
      (
         stderr, 
         "ERROR: Must have Width>=55 && Height>=25 to use \"set\" mode.\n"
      );
      exit(666);
   }
   GameGrid[ 5][11] = Charset[1];
   GameGrid[ 6][12] = Charset[1];
   GameGrid[ 7][10] = Charset[1];
   GameGrid[ 7][11] = Charset[1];
   GameGrid[ 7][12] = Charset[1];
  
   GameGrid[20][21] = Charset[1];
   GameGrid[21][22] = Charset[1];
   GameGrid[22][20] = Charset[1];
   GameGrid[22][21] = Charset[1];
   GameGrid[22][22] = Charset[1];

   GameGrid[15][31] = Charset[1];
   GameGrid[16][32] = Charset[1];
   GameGrid[17][30] = Charset[1];
   GameGrid[17][31] = Charset[1];
   GameGrid[17][32] = Charset[1];
  
   GameGrid[ 9][41] = Charset[1];
   GameGrid[10][42] = Charset[1];
   GameGrid[11][40] = Charset[1];
   GameGrid[11][41] = Charset[1];
   GameGrid[11][42] = Charset[1];

   GameGrid[17][51] = Charset[1];
   GameGrid[18][52] = Charset[1];
   GameGrid[19][50] = Charset[1];
   GameGrid[19][51] = Charset[1];
   GameGrid[19][52] = Charset[1];
   return;
}

/* Randomize the game grid: */
void RandomizeGameGrid (void)
{
   int Row,Col,r;
   for ( Row = 0 ; Row < Height ; ++Row )
   {
      for ( Col = 0 ; Col < Width ; ++Col )
      {
         r = (int)floor(1.15 * (double)rand() / (double)RAND_MAX);
         GameGrid[Row][Col] = r ? Charset[1] : Charset[0];
      }
   }
   return;
}

/* Write the game grid to the screen: */
void WriteGameGrid (void)
{
   int i,j;
   for ( j = 0 ; j < Height ; ++j )
   {
      for ( i = 0 ; i < Width ; ++i )
      {
         WriteChar(GameGrid[j][i], j, i, NCC_RED_CYAN);
      }
   }
   return;
}

/* Calculate number of neighbors for each cell: */
int Neighbors (int Row, int Col)
{
   int Above, Below, Left, Right;
   int a,b,c,d,e,f,g,h,N;
   if (Row ==    0    ) {Above = Height-1;} else {Above = Row-1;}
   if (Row == Height-1) {Below =    0    ;} else {Below = Row+1;}
   if (Col ==    0    ) {Left  = Width-1 ;} else {Left  = Col-1;}
   if (Col == Width -1) {Right =    0    ;} else {Right = Col+1;}
   a = (GameGrid[Above][Left   ] == Charset[1]) ? 1 : 0;
   b = (GameGrid[Above][Col    ] == Charset[1]) ? 1 : 0;
   c = (GameGrid[Above][Right  ] == Charset[1]) ? 1 : 0;
   d = (GameGrid[Row  ][Right  ] == Charset[1]) ? 1 : 0;
   e = (GameGrid[Below][Right  ] == Charset[1]) ? 1 : 0;
   f = (GameGrid[Below][Col    ] == Charset[1]) ? 1 : 0;
   g = (GameGrid[Below][Left   ] == Charset[1]) ? 1 : 0;
   h = (GameGrid[Row  ][Left   ] == Charset[1]) ? 1 : 0;
   N = a+b+c+d+e+f+g+h;
   return N;
}

/* Calculate fate of next generation: */
void Fate (void)
{
   int Row, Col, N;
   for ( Row = 0 ; Row < Height ; ++Row )
   {
      for ( Col = 0 ; Col < Width ; ++Col )
      {
         N = Neighbors(Row, Col);
         if (Charset[1] == GameGrid[Row][Col])  /* if live cell */
         {
            if (2 == N || 3 == N)               /* if moderate neighbors */
            {
               FateGrid[Row][Col] = Charset[1]; /* survive */
            }
            else                                /* if crowded or lonely */
            {
               FateGrid[Row][Col] = Charset[0]; /* die */
            }
         }
         else                                   /* if dead cell */
         {
            if (3 == N)                         /* if optimal neighbors */
            {
               FateGrid[Row][Col] = Charset[1]; /* spawn */
            }
            else                                /* if crowded or lonely */
            {
               FateGrid[Row][Col] = Charset[0]; /* don't spawn */
            }
         }
      }
   }
   return;
}   

/* Set game grid to next generation: */
void NextGen (void)
{
   int Row, Col;
   /* Calculate fate for each cell: */
   Fate();                                         
   /* Cause each cell to meet its fate: */
   for ( Row = 0 ; Row < Height ; ++Row )
   {
      for ( Col = 0 ; Col < Width ; ++Col )
      {
         GameGrid[Row][Col] = FateGrid[Row][Col]; 
      }
   }
   return;
}

/* Get high-resolution time (time in seconds, to nearest microsecond, since
00:00:00 on the morning of Jan 1, 1970) as double (for timing things): */
double HiResTime (void)
{
   struct timeval t;
   gettimeofday(&t, NULL);
   return (double)t.tv_sec + (double)t.tv_usec / 1000000.0;
}

/* Delay for a given time in seconds (resolution is theoretically 1us): */
void Delay (double s)
{
   double t0  = 0.0;
   double t   = 0.0;
   double n   = 1.000013;
   double m   = 1.001867;
   int    i;

   t0 = HiResTime();
   for ( t = t0 ; t - t0 < s ; t = HiResTime() )
   {
      for ( i = 0 ; i < 5 ; i = i + (int)n )
      {
         while ( n < 8.0) {n *= m;}
         while ( n > 2.0) {n /= m;}
      }
   }
   return;
}

/* Program entry point: */
int main (int Robin, char * Marian[])
{
   int     c       = 0;
   double  Number  = 0.0;
   double  Speed   = 5.0;
   bool    Pause   = false;
   bool    Set     = false;

   if (Robin > 1)
   {
      Number = (int)strtod(Marian[1], NULL);
      if (Number >= 1.0 && Number <= 1000.0)
      {
         Speed = Number;
      }
   }

   if (Robin > 2)
   {
      if (Marian[2][0] == 's')
      {
         Set = true;
      }
   }

   /* Initialize GameGrid and FateGrid arrays to all '\0': */
   InitArrays();

   /* Enter curses to get Height and Width,
   before attempting to initialize game grid: */
   EnterCurses();

   /* Initialize the game-grid portion of GameGrid array
   to all space characters (' '): */
   InitGameGrid();

   /* Seed the pseudo-random-number generator: */
   srand((unsigned)time(NULL));

   /* If using a set pattern, set the grid to the pattern: */
   if (Set)
   {
      SetGameGrid();
   }

   /* Otherwise, randomize the grid: */
   else
   {
      RandomizeGameGrid();
   }

   /* Enter main game loop: */
   while ( 1 )
   {
      if (!Pause) {WriteGameGrid();}
      Delay(1.0/Speed);
      c = getch();
      if ('q' == (char)c) break;
      if ('p' == (char)c) Pause = !Pause;
      if ('r' == (char)c) {RandomizeGameGrid();WriteGameGrid();}
      if ('n' == (char)c) {Pause=true;NextGen();WriteGameGrid();}
      if ('f' == (char)c) {Speed*=1.5;if(Speed>1000.0){Speed=1000.0;}}
      if ('s' == (char)c) {Speed/=1.5;if(Speed<1.0){Speed=1.0;}}
      if (!Pause) {NextGen();}
   }
   ExitCurses();
   return 0;
}
